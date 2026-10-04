from fastapi import FastAPI, Depends, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from sqlalchemy.orm import Session

import random

import models
from database import engine, get_db
from ai_monitor import analyze_inspection


# ============================================================
# CREATE DATABASE TABLES
# ============================================================

models.Base.metadata.create_all(bind=engine)


# ============================================================
# FASTAPI APPLICATION
# ============================================================

app = FastAPI(
    title="DoSJE Smart Inspection System",
    description="AI-powered monitoring and surprise inspection platform",
    version="1.0"
)


# ============================================================
# CORS
# ============================================================

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============================================================
# TEMPLATES
# ============================================================

templates = Jinja2Templates(directory="templates")


# ============================================================
# HOME
# ============================================================

@app.get("/")
def home():
    return {
        "message": "DoSJE Smart Inspection System is running",
        "status": "success"
    }


# ============================================================
# HEALTH CHECK
# ============================================================

@app.get("/health")
def health():
    return {
        "status": "healthy"
    }


# ============================================================
# PROJECTS
# ============================================================

@app.post("/projects")
def create_project(
    name: str,
    location: str,
    db: Session = Depends(get_db)
):
    project = models.Project(
        name=name,
        location=location
    )

    db.add(project)
    db.commit()
    db.refresh(project)

    return project


@app.get("/projects")
def get_projects(
    db: Session = Depends(get_db)
):
    return db.query(models.Project).all()


# ============================================================
# INSPECTORS
# ============================================================

@app.post("/inspectors")
def create_inspector(
    name: str,
    district: str,
    db: Session = Depends(get_db)
):
    inspector = models.Inspector(
        name=name,
        district=district
    )

    db.add(inspector)
    db.commit()
    db.refresh(inspector)

    return inspector


@app.get("/inspectors")
def get_inspectors(
    db: Session = Depends(get_db)
):
    return db.query(models.Inspector).all()


# ============================================================
# RANDOM INSPECTION ASSIGNMENT
# ============================================================

@app.post("/assign-inspection")
def assign_inspection(
    project_id: int,
    db: Session = Depends(get_db)
):

    # Check whether project exists
    project = db.query(models.Project).filter(
        models.Project.id == project_id
    ).first()

    if not project:
        return {
            "error": "Project not found"
        }

    # Find available inspectors
    inspectors = db.query(models.Inspector).filter(
        models.Inspector.status == "Available"
    ).all()

    if not inspectors:
        return {
            "error": "No available inspectors"
        }

    # Randomly select inspector
    inspector = random.choice(inspectors)

    # Create inspection
    inspection = models.Inspection(
        project_id=project.id,
        inspector_id=inspector.id,
        status="Pending"
    )

    db.add(inspection)

    # Mark inspector as assigned
    inspector.status = "Assigned"

    db.commit()
    db.refresh(inspection)

    return {
        "message": "Inspection assigned successfully",
        "inspection_id": inspection.id,
        "project": project.name,
        "inspector": inspector.name,
        "district": inspector.district,
        "status": inspection.status
    }


# ============================================================
# GET ALL INSPECTIONS
# ============================================================

@app.get("/inspections")
def get_inspections(
    db: Session = Depends(get_db)
):

    inspections = db.query(models.Inspection).all()

    result = []

    for inspection in inspections:

        project = db.query(models.Project).filter(
            models.Project.id == inspection.project_id
        ).first()

        inspector = db.query(models.Inspector).filter(
            models.Inspector.id == inspection.inspector_id
        ).first()

        result.append({

            "inspection_id": inspection.id,

            "project": (
                project.name
                if project
                else "Unknown"
            ),

            "location": (
                project.location
                if project
                else "Unknown"
            ),

            "inspector": (
                inspector.name
                if inspector
                else "Unknown"
            ),

            "district": (
                inspector.district
                if inspector
                else "Unknown"
            ),

            "status": inspection.status,

            "remarks": inspection.remarks,

            "latitude": inspection.latitude,

            "longitude": inspection.longitude,

            "evidence": inspection.evidence,

            "anomaly_result": inspection.anomaly_result
        })

    return result


# ============================================================
# COMPLETE INSPECTION
# ============================================================

@app.put("/inspections/{inspection_id}")
def complete_inspection(
    inspection_id: int,
    remarks: str,
    latitude: str,
    longitude: str,
    evidence: str,
    anomaly_result: str,
    db: Session = Depends(get_db)
):

    inspection = db.query(models.Inspection).filter(
        models.Inspection.id == inspection_id
    ).first()

    if not inspection:
        return {
            "error": "Inspection not found"
        }

    inspection.remarks = remarks
    inspection.latitude = latitude
    inspection.longitude = longitude
    inspection.evidence = evidence

    inspection.anomaly_result = anomaly_result

    inspection.status = "Completed"

    db.commit()
    db.refresh(inspection)

    return {

        "message": "Inspection completed successfully",

        "inspection_id": inspection.id,

        "status": inspection.status,

        "remarks": inspection.remarks,

        "latitude": inspection.latitude,

        "longitude": inspection.longitude,

        "evidence": inspection.evidence,

        "anomaly_result": inspection.anomaly_result
    }


# ============================================================
# AI MONITORING - SINGLE INSPECTION
# ============================================================

@app.post("/ai-monitor/{inspection_id}")
def run_ai_monitor(
    inspection_id: int,
    db: Session = Depends(get_db)
):

    # Find inspection
    inspection = db.query(models.Inspection).filter(
        models.Inspection.id == inspection_id
    ).first()

    if not inspection:
        return {
            "error": "Inspection not found"
        }

    # Run AI monitoring engine
    result = analyze_inspection(

        status=inspection.status,

        remarks=inspection.remarks,

        latitude=inspection.latitude,

        longitude=inspection.longitude,

        evidence=inspection.evidence
    )

    # Save AI result in database
    inspection.anomaly_result = (
        result["result"]
        + " | Risk Score: "
        + str(result["risk_score"])
    )

    db.commit()
    db.refresh(inspection)

    return {

        "inspection_id": inspection.id,

        "risk_score": result["risk_score"],

        "result": result["result"],

        "alerts": result["alerts"]
    }


# ============================================================
# AI MONITORING - ALL INSPECTIONS
# ============================================================

@app.get("/ai-monitor")
def get_ai_monitoring(
    db: Session = Depends(get_db)
):

    inspections = db.query(models.Inspection).all()

    monitoring = []

    for inspection in inspections:

        # Run AI analysis
        result = analyze_inspection(

            status=inspection.status,

            remarks=inspection.remarks,

            latitude=inspection.latitude,

            longitude=inspection.longitude,

            evidence=inspection.evidence
        )

        # Get project
        project = db.query(models.Project).filter(
            models.Project.id == inspection.project_id
        ).first()

        # Get inspector
        inspector = db.query(models.Inspector).filter(
            models.Inspector.id == inspection.inspector_id
        ).first()

        monitoring.append({

            "inspection_id": inspection.id,

            "project": (
                project.name
                if project
                else "Unknown"
            ),

            "inspector": (
                inspector.name
                if inspector
                else "Unknown"
            ),

            "risk_score": result["risk_score"],

            "result": result["result"],

            "alerts": result["alerts"]
        })

    return monitoring


# ============================================================
# DASHBOARD
# ============================================================

@app.get(
    "/dashboard",
    response_class=HTMLResponse
)
def dashboard(request: Request):

    return templates.TemplateResponse(

        request=request,

        name="dashboard.html"
    )