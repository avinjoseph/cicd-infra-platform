"""
Sample service for the CI/CD & Infrastructure Automation Platform demo.

A tiny FastAPI app exists here mainly to give the pipeline something
real to test, scan, containerize, and deploy. The interesting part of
this project is the automation around it, not the app itself.
"""
from datetime import datetime, timezone

from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="CI/CD Infra Automation Demo", version="1.0.0")


class HealthResponse(BaseModel):
    status: str
    timestamp: str
    version: str


class EchoRequest(BaseModel):
    message: str


class EchoResponse(BaseModel):
    message: str
    length: int


@app.get("/", response_model=HealthResponse)
def root() -> HealthResponse:
    """Root endpoint, also used as a liveness check."""
    return HealthResponse(
        status="ok",
        timestamp=datetime.now(timezone.utc).isoformat(),
        version=app.version,
    )


@app.get("/health", response_model=HealthResponse)
def health() -> HealthResponse:
    """
    Health endpoint used by the deployment validation script.

    Kept separate from '/' so infra checks can target a stable,
    dependency-free path even if other routes change.
    """
    return HealthResponse(
        status="ok",
        timestamp=datetime.now(timezone.utc).isoformat(),
        version=app.version,
    )


@app.post("/echo", response_model=EchoResponse)
def echo(payload: EchoRequest) -> EchoResponse:
    """Simple endpoint so there's business logic worth unit testing."""
    return EchoResponse(message=payload.message, length=len(payload.message))
