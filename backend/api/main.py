from fastapi import FastAPI
from .get_categories import router as categories_router
from .recipe_ranking import router as ranking_router
from dotenv import load_dotenv

load_dotenv()

app = FastAPI()
app.include_router(categories_router, prefix="/api")
app.include_router(ranking_router, prefix="/api")
