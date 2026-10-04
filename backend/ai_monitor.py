def analyze_inspection(
    status,
    remarks,
    latitude,
    longitude,
    evidence
):
    """
    AI Monitoring Engine - initial MVP version.

    Returns a risk score and monitoring result
    based on inspection information.
    """

    risk_score = 0
    alerts = []

    # 1. Inspection status
    if not status or status.lower() != "completed":
        risk_score += 20
        alerts.append("Inspection is not completed")

    # 2. GPS verification
    if not latitude or not longitude:
        risk_score += 25
        alerts.append("GPS location is missing")

    # 3. Evidence verification
    if not evidence or not evidence.strip():
        risk_score += 25
        alerts.append("Inspection evidence is missing")

    # 4. Remarks verification
    if not remarks or not remarks.strip():
        risk_score += 15
        alerts.append("Inspection remarks are missing")

    # 5. Detect issue-related words in remarks
    if remarks:
        text = remarks.lower()

        issue_words = [
            "problem",
            "issue",
            "missing",
            "absent",
            "damage",
            "irregular",
            "fraud",
            "mismatch",
            "not available",
            "violation"
        ]

        detected_words = []

        for word in issue_words:
            if word in text:
                detected_words.append(word)

        if detected_words:
            risk_score += 15
            alerts.append(
                "Potential issue detected: "
                + ", ".join(detected_words)
            )

    # Maximum score
    risk_score = min(risk_score, 100)

    # Final monitoring result
    if risk_score >= 50:
        result = "HIGH RISK"
    elif risk_score >= 25:
        result = "MEDIUM RISK"
    else:
        result = "LOW RISK"

    return {
        "risk_score": risk_score,
        "result": result,
        "alerts": alerts
    }