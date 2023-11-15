# Deployment
# Import libraries
import streamlit as st
import psycopg2
import os
import time
import vertexai
from vertexai.language_models import TextGenerationModel
# from env import *

# Database Credentials
DBNAME=os.getenv("DBNAME")
USER=os.getenv("USER")
HOST= os.getenv("HOST")
DBPORT=os.getenv("DBPORT")
DBPASSWORD=os.getenv("DBPASSWORD")
# Cloud
PROJECT_NAME=os.getenv("PROJECT_NAME")

#----------Page Configuration----------# 
st.set_page_config(page_title="Matt Cloud Tech",
                   page_icon=":cloud:",
                   menu_items={
                       'About':"# Matt Cloud Tech"})

st.write(DBNAME)