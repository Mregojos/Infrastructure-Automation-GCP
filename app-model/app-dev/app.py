import streamlit as st
import os

DBNAME=os.getenv('DBNAME')
USER=os.getenv('USER')
HOST=os.getenv('HOST')

st.write("It's working")
st.text(DBNAME)
st.text(USER)
st.text(HOST)