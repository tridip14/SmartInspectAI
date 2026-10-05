from sqlalchemy import Column, Integer, String, Text, DateTime, Float, Boolean
from database import Base
from datetime import datetime


# ============================================================
# USERS
# ============================================================

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, nullable=False)
    password = Column(String, nullable=False)
    role = Column(String, nullable=False)
    district = Column(String, nullable=True)
    state = Column(String, nullable=True)
    status = Column(String, default="Active")


# ============================================================
# PROJECTS / INSTITUTES / NGOs
# ============================================================

class Project(Base):
    __tablename__ = "projects"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    location = Column(String, nullable=False)
    district = Column(String, nullable=True)
    state = Column(String, nullable=True)
    scheme = Column(String, nullable=True)
    organization = Column(String, nullable=True)
    project_incharge = Column(String, nullable=True)
    contact = Column(String, nullable=True)

    latitude = Column(String, nullable=True)
    longitude = Column(String, nullable=True)

    beneficiary_capacity = Column(Integer, default=0)
    beneficiary_count = Column(Integer, default=0)
    staff_count = Column(Integer, default=0)

    cctv_status = Column(String, default="Unknown")
    status = Column(String, default="Active")

    created_at = Column(DateTime, default=datetime.utcnow)


# ============================================================
# INSPECTORS
# ============================================================

class Inspector(Base):
    __tablename__ = "inspectors"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    district = Column(String, nullable=False)
    state = Column(String, nullable=True)
    phone = Column(String, nullable=True)
    email = Column(String, nullable=True)

    status = Column(String, default="Available")

    total_assignments = Column(Integer, default=0)
    completed_inspections = Column(Integer, default=0)

    created_at = Column(DateTime, default=datetime.utcnow)


# ============================================================
# INSPECTIONS
# ============================================================

class Inspection(Base):
    __tablename__ = "inspections"

    id = Column(Integer, primary_key=True, index=True)

    project_id = Column(Integer, nullable=False)
    inspector_id = Column(Integer, nullable=False)

    inspection_type = Column(
        String,
        default="Surprise Inspection"
    )

    status = Column(String, default="Pending")

    remarks = Column(Text, nullable=True)

    latitude = Column(String, nullable=True)
    longitude = Column(String, nullable=True)

    evidence = Column(Text, nullable=True)

    anomaly_result = Column(Text, nullable=True)

    risk_score = Column(Float, default=0)

    risk_level = Column(String, default="LOW")

    checklist_score = Column(Float, default=0)

    started_at = Column(DateTime, nullable=True)
    completed_at = Column(DateTime, nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow)


# ============================================================
# INSPECTION CHECKLIST
# ============================================================

class InspectionChecklist(Base):
    __tablename__ = "inspection_checklists"

    id = Column(Integer, primary_key=True, index=True)

    inspection_id = Column(Integer, nullable=False)

    infrastructure = Column(String, default="Not Checked")
    staff_present = Column(String, default="Not Checked")
    beneficiaries_present = Column(String, default="Not Checked")
    attendance_verified = Column(String, default="Not Checked")
    records_maintained = Column(String, default="Not Checked")
    scheme_activities = Column(String, default="Not Checked")
    facilities_operational = Column(String, default="Not Checked")
    cctv_operational = Column(String, default="Not Checked")
    safety_conditions = Column(String, default="Not Checked")

    remarks = Column(Text, nullable=True)

    score = Column(Float, default=0)

    created_at = Column(DateTime, default=datetime.utcnow)


# ============================================================
# EVIDENCE
# ============================================================

class Evidence(Base):
    __tablename__ = "evidence"

    id = Column(Integer, primary_key=True, index=True)

    inspection_id = Column(Integer, nullable=False)
    project_id = Column(Integer, nullable=False)

    file_name = Column(String, nullable=False)
    file_type = Column(String, nullable=True)
    file_path = Column(String, nullable=True)

    description = Column(Text, nullable=True)

    latitude = Column(String, nullable=True)
    longitude = Column(String, nullable=True)

    ai_detection = Column(Text, nullable=True)
    ai_confidence = Column(Float, nullable=True)

    captured_at = Column(DateTime, default=datetime.utcnow)

    verified = Column(Boolean, default=False)


# ============================================================
# ATTENDANCE
# ============================================================

class Attendance(Base):
    __tablename__ = "attendance"

    id = Column(Integer, primary_key=True, index=True)

    inspection_id = Column(Integer, nullable=False)
    project_id = Column(Integer, nullable=False)

    expected_beneficiaries = Column(Integer, default=0)
    reported_beneficiaries = Column(Integer, default=0)
    observed_beneficiaries = Column(Integer, default=0)

    staff_expected = Column(Integer, default=0)
    staff_present = Column(Integer, default=0)

    attendance_percentage = Column(Float, default=0)

    anomaly_score = Column(Float, default=0)

    anomaly_status = Column(String, default="NORMAL")

    remarks = Column(Text, nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow)


# ============================================================
# CCTV CAMERAS
# ============================================================

class CCTVCamera(Base):
    __tablename__ = "cctv_cameras"

    id = Column(Integer, primary_key=True, index=True)

    project_id = Column(Integer, nullable=False)

    camera_name = Column(String, nullable=False)

    camera_url = Column(String, nullable=True)

    location = Column(String, nullable=True)

    status = Column(String, default="Offline")

    last_active = Column(DateTime, nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow)


# ============================================================
# VIDEO CONFERENCE SESSIONS
# ============================================================

class VCSession(Base):
    __tablename__ = "vc_sessions"

    id = Column(Integer, primary_key=True, index=True)

    project_id = Column(Integer, nullable=False)
    inspector_id = Column(Integer, nullable=True)

    participant_type = Column(String, nullable=True)
    participant_name = Column(String, nullable=True)

    meeting_url = Column(String, nullable=True)

    status = Column(String, default="Scheduled")

    remarks = Column(Text, nullable=True)

    started_at = Column(DateTime, nullable=True)
    ended_at = Column(DateTime, nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow)


# ============================================================
# AI ANALYSIS
# ============================================================

class AIAnalysis(Base):
    __tablename__ = "ai_analysis"

    id = Column(Integer, primary_key=True, index=True)

    inspection_id = Column(Integer, nullable=False)

    risk_score = Column(Float, default=0)

    risk_level = Column(String, default="LOW")

    anomaly_type = Column(String, nullable=True)

    detection_result = Column(Text, nullable=True)

    confidence = Column(Float, nullable=True)

    recommendation = Column(Text, nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow)


# ============================================================
# COMPLAINTS / INCIDENTS
# ============================================================

class Complaint(Base):
    __tablename__ = "complaints"

    id = Column(Integer, primary_key=True, index=True)

    project_id = Column(Integer, nullable=True)

    complaint_source = Column(String, nullable=True)

    description = Column(Text, nullable=False)

    evidence = Column(Text, nullable=True)

    status = Column(String, default="Open")

    assigned_to = Column(Integer, nullable=True)

    resolution = Column(Text, nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow)

    resolved_at = Column(DateTime, nullable=True)


# ============================================================
# NOTIFICATIONS
# ============================================================

class Notification(Base):
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True)

    user_id = Column(Integer, nullable=False)

    title = Column(String, nullable=False)

    message = Column(Text, nullable=False)

    notification_type = Column(String, nullable=True)

    is_read = Column(Boolean, default=False)

    created_at = Column(DateTime, default=datetime.utcnow)


# ============================================================
# AUDIT LOGS
# ============================================================

class AuditLog(Base):
    __tablename__ = "audit_logs"

    id = Column(Integer, primary_key=True, index=True)

    user_id = Column(Integer, nullable=True)

    action = Column(String, nullable=False)

    module = Column(String, nullable=True)

    description = Column(Text, nullable=True)

    ip_address = Column(String, nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow)