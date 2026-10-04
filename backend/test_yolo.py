from ultralytics import YOLO

# Load pothole model
model = YOLO("best.pt")

# Detect potholes
results = model("test.png", save=True, conf=0.25)

print("Pothole detection completed!")