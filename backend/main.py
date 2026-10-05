from fastapi import FastAPI, Depends, HTTPException, UploadFile, File
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session

from database import engine, get_db
import models

import random
import os
import shutil
from datetime import datetime


# ============================================================
# DATABASE
# ============================================================

models.Base.metadata.create_all(bind=engine)


# ============================================================
# PYDANTIC REQUEST MODELS
# ============================================================

class LoginRequest(BaseModel):
    email: str
    password: str


# ============================================================
# APPLICATION
# ============================================================

app = FastAPI(
    title="DoSJE SmartInspectAI",
    description="Government Smart Monitoring, Inspection and AI Analytics Platform",
    version="2.0"
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
# HOME / HEALTH
# ============================================================

@app.get("/")
def home():
    return {
        "message": "DoSJE SmartInspectAI is running",
        "status": "success",
        "version": "2.0"
    }


@app.get("/health")
def health():
    return {
        "status": "healthy",
        "service": "DoSJE SmartInspectAI"
    }


# ============================================================
# USERS
# ============================================================

@app.post("/users")
def create_user(
    name: str,
    email: str,
    password: str,
    role: str,
    district: str = "",
    state: str = "",
    db: Session = Depends(get_db)
):
    existing = db.query(models.User).filter(
        models.User.email == email
    ).first()

    if existing:
        raise HTTPException(
            status_code=400,
            detail="User already exists"
        )

    user = models.User(
        name=name,
        email=email,
        password=password,
        role=role,
        district=district,
        state=state
    )

    db.add(user)
    db.commit()
    db.refresh(user)

    return {
        "message": "User created successfully",
        "user_id": user.id,
        "name": user.name,
        "role": user.role
    }


# ============================================================
# LOGIN
# ============================================================

@app.post("/auth/login")
def login(
    login_data: LoginRequest,
    db: Session = Depends(get_db)
):
    user = db.query(models.User).filter(
        models.User.email == login_data.email,
        models.User.password == login_data.password
    ).first()

    if not user:
        raise HTTPException(
            status_code=401,
            detail="Invalid email or password"
        )

    return {
        "message": "Login successful",
        "user_id": user.id,
        "name": user.name,
        "email": user.email,
        "role": user.role,
        "district": user.district,
        "state": user.state
    }


@app.get("/users")
def get_users(db: Session = Depends(get_db)):
    return db.query(models.User).all()


# ============================================================
# PROJECTS
# ============================================================

@app.post("/projects")
def create_project(
    name: str,
    location: str,
    district: str = "",
    state: str = "",
    scheme: str = "",
    organization: str = "",
    project_incharge: str = "",
    contact: str = "",
    latitude: str = "",
    longitude: str = "",
    beneficiary_capacity: int = 0,
    beneficiary_count: int = 0,
    staff_count: int = 0,
    db: Session = Depends(get_db)
):
    project = models.Project(
        name=name,
        location=location,
        district=district,
        state=state,
        scheme=scheme,
        organization=organization,
        project_incharge=project_incharge,
        contact=contact,
        latitude=latitude,
        longitude=longitude,
        beneficiary_capacity=beneficiary_capacity,
        beneficiary_count=beneficiary_count,
        staff_count=staff_count
    )

    db.add(project)
    db.commit()
    db.refresh(project)

    return project


@app.get("/projects")
def get_projects(db: Session = Depends(get_db)):
    return db.query(models.Project).all()


@app.get("/projects/{project_id}")
def get_project(
    project_id: int,
    db: Session = Depends(get_db)
):
    project = db.query(models.Project).filter(
        models.Project.id == project_id
    ).first()

    if not project:
        raise HTTPException(
            status_code=404,
            detail="Project not found"
        )

    return project


# ============================================================
# INSPECTORS
# ============================================================

@app.post("/inspectors")
def create_inspector(
    name: str,
    district: str,
    state: str = "",
    phone: str = "",
    email: str = "",
    db: Session = Depends(get_db)
):
    inspector = models.Inspector(
        name=name,
        district=district,
        state=state,
        phone=phone,
        email=email
    )

    db.add(inspector)
    db.commit()
    db.refresh(inspector)

    return inspector


@app.get("/inspectors")
def get_inspectors(db: Session = Depends(get_db)):
    return db.query(models.Inspector).all()


# ============================================================
# RANDOM INSPECTION ASSIGNMENT
# ============================================================

@app.post("/assign-inspection")
def assign_inspection(
    project_id: int,
    db: Session = Depends(get_db)
):
    project = db.query(models.Project).filter(
        models.Project.id == project_id
    ).first()

    if not project:
        raise HTTPException(
            status_code=404,
            detail="Project not found"
        )

    inspectors = db.query(models.Inspector).filter(
        models.Inspector.status == "Available"
    ).all()

    if not inspectors:
        raise HTTPException(
            status_code=400,
            detail="No available inspectors"
        )

    inspector = random.choice(inspectors)

    inspection = models.Inspection(
        project_id=project.id,
        inspector_id=inspector.id,
        inspection_type="Surprise Inspection",
        status="Pending"
    )

    db.add(inspection)

    inspector.status = "Assigned"
    inspector.total_assignments += 1

    db.commit()
    db.refresh(inspection)

    return {
        "message": "Random inspection assigned successfully",
        "inspection_id": inspection.id,
        "project": project.name,
        "inspector": inspector.name,
        "district": inspector.district,
        "status": inspection.status
    }


# ============================================================
# INSPECTIONS
# ============================================================

@app.get("/inspections")
def get_inspections(db: Session = Depends(get_db)):
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
            "project": project.name if project else "Unknown",
            "location": project.location if project else "Unknown",
            "inspector": inspector.name if inspector else "Unknown",
            "district": inspector.district if inspector else "Unknown",
            "status": inspection.status,
            "inspection_type": inspection.inspection_type,
            "remarks": inspection.remarks,
            "latitude": inspection.latitude,
            "longitude": inspection.longitude,
            "evidence": inspection.evidence,
            "anomaly_result": inspection.anomaly_result,
            "risk_score": inspection.risk_score,
            "risk_level": inspection.risk_level
        })

    return result


@app.get("/inspections/{inspection_id}")
def get_inspection(
    inspection_id: int,
    db: Session = Depends(get_db)
):
    inspection = db.query(models.Inspection).filter(
        models.Inspection.id == inspection_id
    ).first()

    if not inspection:
        raise HTTPException(
            status_code=404,
            detail="Inspection not found"
        )

    return inspection


# ============================================================
# COMPLETE INSPECTION
# ============================================================

@app.put("/inspections/{inspection_id}")
def complete_inspection(
    inspection_id: int,
    remarks: str = "",
    latitude: str = "",
    longitude: str = "",
    evidence: str = "",
    anomaly_result: str = "",
    db: Session = Depends(get_db)
):
    inspection = db.query(models.Inspection).filter(
        models.Inspection.id == inspection_id
    ).first()

    if not inspection:
        raise HTTPException(
            status_code=404,
            detail="Inspection not found"
        )

    inspection.remarks = remarks
    inspection.latitude = latitude
    inspection.longitude = longitude
    inspection.evidence = evidence
    inspection.anomaly_result = anomaly_result
    inspection.status = "Completed"
    inspection.completed_at = datetime.utcnow()

    inspector = db.query(models.Inspector).filter(
        models.Inspector.id == inspection.inspector_id
    ).first()

    if inspector:
        inspector.status = "Available"
        inspector.completed_inspections += 1

    db.commit()
    db.refresh(inspection)

    return {
        "message": "Inspection completed successfully",
        "inspection_id": inspection.id,
        "status": inspection.status
    }


# ============================================================
# INSPECTION CHECKLIST
# ============================================================

@app.post("/inspections/{inspection_id}/checklist")
def create_checklist(
    inspection_id: int,
    infrastructure: str = "Not Checked",
    staff_present: str = "Not Checked",
    beneficiaries_present: str = "Not Checked",
    attendance_verified: str = "Not Checked",
    records_maintained: str = "Not Checked",
    scheme_activities: str = "Not Checked",
    facilities_operational: str = "Not Checked",
    cctv_operational: str = "Not Checked",
    safety_conditions: str = "Not Checked",
    remarks: str = "",
    db: Session = Depends(get_db)
):
    inspection = db.query(models.Inspection).filter(
        models.Inspection.id == inspection_id
    ).first()

    if not inspection:
        raise HTTPException(
            status_code=404,
            detail="Inspection not found"
        )

    values = [
        infrastructure,
        staff_present,
        beneficiaries_present,
        attendance_verified,
        records_maintained,
        scheme_activities,
        facilities_operational,
        cctv_operational,
        safety_conditions
    ]

    passed = sum(
        1 for value in values
        if value.upper() == "PASS"
    )

    score = (passed / len(values)) * 100

    checklist = models.InspectionChecklist(
        inspection_id=inspection_id,
        infrastructure=infrastructure,
        staff_present=staff_present,
        beneficiaries_present=beneficiaries_present,
        attendance_verified=attendance_verified,
        records_maintained=records_maintained,
        scheme_activities=scheme_activities,
        facilities_operational=facilities_operational,
        cctv_operational=cctv_operational,
        safety_conditions=safety_conditions,
        remarks=remarks,
        score=score
    )

    inspection.checklist_score = score

    db.add(checklist)
    db.commit()
    db.refresh(checklist)

    return {
        "message": "Checklist submitted",
        "checklist_id": checklist.id,
        "score": score
    }


@app.get("/inspections/{inspection_id}/checklist")
def get_checklist(
    inspection_id: int,
    db: Session = Depends(get_db)
):
    return db.query(
        models.InspectionChecklist
    ).filter(
        models.InspectionChecklist.inspection_id == inspection_id
    ).all()


# ============================================================
# EVIDENCE
# ============================================================

@app.post("/inspections/{inspection_id}/evidence")
async def upload_evidence(
    inspection_id: int,
    file: UploadFile = File(...),
    project_id: int = 0,
    description: str = "",
    latitude: str = "",
    longitude: str = "",
    db: Session = Depends(get_db)
):
    inspection = db.query(models.Inspection).filter(
        models.Inspection.id == inspection_id
    ).first()

    if not inspection:
        raise HTTPException(
            status_code=404,
            detail="Inspection not found"
        )

    os.makedirs("evidence", exist_ok=True)

    filename = (
        f"{inspection_id}_"
        f"{datetime.utcnow().timestamp()}_"
        f"{file.filename}"
    )

    filepath = os.path.join(
        "evidence",
        filename
    )

    with open(filepath, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    evidence = models.Evidence(
        inspection_id=inspection_id,
        project_id=project_id,
        file_name=file.filename,
        file_type=file.content_type,
        file_path=filepath,
        description=description,
        latitude=latitude,
        longitude=longitude
    )

    db.add(evidence)
    db.commit()
    db.refresh(evidence)

    return {
        "message": "Evidence uploaded successfully",
        "evidence_id": evidence.id,
        "file_name": file.filename,
        "location": {
            "latitude": latitude,
            "longitude": longitude
        }
    }


@app.get("/inspections/{inspection_id}/evidence")
def get_evidence(
    inspection_id: int,
    db: Session = Depends(get_db)
):
    return db.query(
        models.Evidence
    ).filter(
        models.Evidence.inspection_id == inspection_id
    ).all()


# ============================================================
# ATTENDANCE
# ============================================================

@app.post("/attendance")
def create_attendance(
    inspection_id: int,
    project_id: int,
    expected_beneficiaries: int,
    reported_beneficiaries: int,
    observed_beneficiaries: int,
    staff_expected: int = 0,
    staff_present: int = 0,
    remarks: str = "",
    db: Session = Depends(get_db)
):
    percentage = 0

    if expected_beneficiaries > 0:
        percentage = (
            observed_beneficiaries /
            expected_beneficiaries
        ) * 100

    difference = abs(
        reported_beneficiaries -
        observed_beneficiaries
    )

    anomaly_score = 0

    if difference >= 20:
        anomaly_score = 80
    elif difference >= 10:
        anomaly_score = 50
    elif difference >= 5:
        anomaly_score = 25

    anomaly_status = (
        "HIGH ANOMALY"
        if anomaly_score >= 50
        else "MEDIUM ANOMALY"
        if anomaly_score >= 25
        else "NORMAL"
    )

    attendance = models.Attendance(
        inspection_id=inspection_id,
        project_id=project_id,
        expected_beneficiaries=expected_beneficiaries,
        reported_beneficiaries=reported_beneficiaries,
        observed_beneficiaries=observed_beneficiaries,
        staff_expected=staff_expected,
        staff_present=staff_present,
        attendance_percentage=percentage,
        anomaly_score=anomaly_score,
        anomaly_status=anomaly_status,
        remarks=remarks
    )

    db.add(attendance)
    db.commit()
    db.refresh(attendance)

    return {
        "message": "Attendance recorded",
        "attendance_percentage": round(percentage, 2),
        "anomaly_score": anomaly_score,
        "anomaly_status": anomaly_status
    }


@app.get("/attendance")
def get_attendance(db: Session = Depends(get_db)):
    return db.query(models.Attendance).all()


# ============================================================
# CCTV
# ============================================================

@app.post("/cctv")
def create_cctv(
    project_id: int,
    camera_name: str,
    camera_url: str = "",
    location: str = "",
    db: Session = Depends(get_db)
):
    camera = models.CCTVCamera(
        project_id=project_id,
        camera_name=camera_name,
        camera_url=camera_url,
        location=location,
        status="Offline"
    )

    db.add(camera)
    db.commit()
    db.refresh(camera)

    return camera


@app.get("/cctv")
def get_cctv(db: Session = Depends(get_db)):
    return db.query(models.CCTVCamera).all()


@app.put("/cctv/{camera_id}/status")
def update_cctv_status(
    camera_id: int,
    status: str,
    db: Session = Depends(get_db)
):
    camera = db.query(models.CCTVCamera).filter(
        models.CCTVCamera.id == camera_id
    ).first()

    if not camera:
        raise HTTPException(
            status_code=404,
            detail="Camera not found"
        )

    camera.status = status
    camera.last_active = datetime.utcnow()

    db.commit()

    return {
        "message": "CCTV status updated",
        "status": status
    }


# ============================================================
# VIDEO CONFERENCE
# ============================================================

@app.post("/vc")
def create_vc_session(
    project_id: int,
    participant_type: str,
    participant_name: str,
    meeting_url: str = "",
    inspector_id: int = 0,
    db: Session = Depends(get_db)
):
    session = models.VCSession(
        project_id=project_id,
        inspector_id=inspector_id,
        participant_type=participant_type,
        participant_name=participant_name,
        meeting_url=meeting_url,
        status="Scheduled"
    )

    db.add(session)
    db.commit()
    db.refresh(session)

    return {
        "message": "VC session created",
        "session_id": session.id,
        "meeting_url": meeting_url
    }


@app.get("/vc")
def get_vc_sessions(db: Session = Depends(get_db)):
    return db.query(models.VCSession).all()


# ============================================================
# AI MONITORING
# ============================================================

@app.post("/ai-monitor/{inspection_id}")
def run_ai_monitor(
    inspection_id: int,
    db: Session = Depends(get_db)
):
    inspection = db.query(models.Inspection).filter(
        models.Inspection.id == inspection_id
    ).first()

    if not inspection:
        raise HTTPException(
            status_code=404,
            detail="Inspection not found"
        )

    risk = 0
    alerts = []

    if inspection.status != "Completed":
        risk += 20
        alerts.append("Inspection incomplete")

    if not inspection.latitude or not inspection.longitude:
        risk += 25
        alerts.append("GPS location missing")

    if not inspection.evidence:
        risk += 25
        alerts.append("Evidence missing")

    if not inspection.remarks:
        risk += 15
        alerts.append("Inspection remarks missing")

    risk = min(risk, 100)

    if risk >= 75:
        level = "CRITICAL"
    elif risk >= 50:
        level = "HIGH"
    elif risk >= 25:
        level = "MEDIUM"
    else:
        level = "LOW"

    result = (
        f"{level} RISK"
        if alerts
        else "No major anomaly detected"
    )

    analysis = models.AIAnalysis(
        inspection_id=inspection_id,
        risk_score=risk,
        risk_level=level,
        anomaly_type="Inspection Risk",
        detection_result=result,
        recommendation=(
            "Priority verification required"
            if risk >= 50
            else "Continue regular monitoring"
        )
    )

    inspection.risk_score = risk
    inspection.risk_level = level
    inspection.anomaly_result = result

    db.add(analysis)
    db.commit()

    return {
        "inspection_id": inspection_id,
        "risk_score": risk,
        "risk_level": level,
        "result": result,
        "alerts": alerts
    }


@app.get("/ai-monitor")
def get_ai_monitoring(db: Session = Depends(get_db)):
    return db.query(models.AIAnalysis).all()


# ============================================================
# COMPLAINTS
# ============================================================

@app.post("/complaints")
def create_complaint(
    description: str,
    project_id: int = 0,
    complaint_source: str = "",
    evidence: str = "",
    db: Session = Depends(get_db)
):
    complaint = models.Complaint(
        project_id=project_id,
        complaint_source=complaint_source,
        description=description,
        evidence=evidence
    )

    db.add(complaint)
    db.commit()
    db.refresh(complaint)

    return {
        "message": "Complaint registered",
        "complaint_id": complaint.id,
        "status": complaint.status
    }


@app.get("/complaints")
def get_complaints(db: Session = Depends(get_db)):
    return db.query(models.Complaint).all()


@app.put("/complaints/{complaint_id}")
def update_complaint(
    complaint_id: int,
    status: str,
    resolution: str = "",
    db: Session = Depends(get_db)
):
    complaint = db.query(models.Complaint).filter(
        models.Complaint.id == complaint_id
    ).first()

    if not complaint:
        raise HTTPException(
            status_code=404,
            detail="Complaint not found"
        )

    complaint.status = status
    complaint.resolution = resolution

    if status == "Closed":
        complaint.resolved_at = datetime.utcnow()

    db.commit()

    return {
        "message": "Complaint updated",
        "status": status
    }


# ============================================================
# NOTIFICATIONS
# ============================================================

@app.post("/notifications")
def create_notification(
    user_id: int,
    title: str,
    message: str,
    notification_type: str = "General",
    db: Session = Depends(get_db)
):
    notification = models.Notification(
        user_id=user_id,
        title=title,
        message=message,
        notification_type=notification_type
    )

    db.add(notification)
    db.commit()
    db.refresh(notification)

    return notification


@app.get("/notifications/{user_id}")
def get_notifications(
    user_id: int,
    db: Session = Depends(get_db)
):
    return db.query(
        models.Notification
    ).filter(
        models.Notification.user_id == user_id
    ).all()


# ============================================================
# AUDIT LOGS
# ============================================================

@app.post("/audit-logs")
def create_audit_log(
    action: str,
    module: str = "",
    description: str = "",
    user_id: int = 0,
    db: Session = Depends(get_db)
):
    log = models.AuditLog(
        user_id=user_id,
        action=action,
        module=module,
        description=description
    )

    db.add(log)
    db.commit()
    db.refresh(log)

    return log


@app.get("/audit-logs")
def get_audit_logs(db: Session = Depends(get_db)):
    return db.query(
        models.AuditLog
    ).order_by(
        models.AuditLog.id.desc()
    ).all()


# ============================================================
# GOVERNMENT DASHBOARD
# ============================================================

@app.get("/dashboard")
def dashboard(db: Session = Depends(get_db)):

    total_projects = db.query(
        models.Project
    ).count()

    total_inspectors = db.query(
        models.Inspector
    ).count()

    total_inspections = db.query(
        models.Inspection
    ).count()

    pending_inspections = db.query(
        models.Inspection
    ).filter(
        models.Inspection.status == "Pending"
    ).count()

    completed_inspections = db.query(
        models.Inspection
    ).filter(
        models.Inspection.status == "Completed"
    ).count()

    available_inspectors = db.query(
        models.Inspector
    ).filter(
        models.Inspector.status == "Available"
    ).count()

    assigned_inspectors = db.query(
        models.Inspector
    ).filter(
        models.Inspector.status == "Assigned"
    ).count()

    high_risk = db.query(
        models.Inspection
    ).filter(
        models.Inspection.risk_level.in_(
            ["HIGH", "CRITICAL"]
        )
    ).count()

    total_complaints = db.query(
        models.Complaint
    ).count()

    open_complaints = db.query(
        models.Complaint
    ).filter(
        models.Complaint.status != "Closed"
    ).count()

    return {
        "total_projects": total_projects,
        "total_inspectors": total_inspectors,
        "total_inspections": total_inspections,
        "pending_inspections": pending_inspections,
        "completed_inspections": completed_inspections,
        "available_inspectors": available_inspectors,
        "assigned_inspectors": assigned_inspectors,
        "high_risk_projects": high_risk,
        "total_complaints": total_complaints,
        "open_complaints": open_complaints
    }