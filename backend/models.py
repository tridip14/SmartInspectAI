from sqlalchemy import Column, Integer, String

from database import Base


class Project(Base):
    __tablename__ = "projects"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    location = Column(String, nullable=False)
    status = Column(String, default="Active")


class Inspector(Base):
    __tablename__ = "inspectors"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    district = Column(String, nullable=False)
    status = Column(String, default="Available")
   
class Inspection(Base):
    __tablename__ = "inspections"

    id = Column(Integer, primary_key=True, index=True)

    project_id = Column(Integer, nullable=False)
    inspector_id = Column(Integer, nullable=False)

    status = Column(String, default="Pending")

    # Inspection details
    remarks = Column(String, nullable=True)

    # GPS coordinates
    latitude = Column(String, nullable=True)
    longitude = Column(String, nullable=True)

    # Evidence
    evidence = Column(String, nullable=True)

    # AI analysis
    anomaly_result = Column(String, nullable=True)