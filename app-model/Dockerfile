FROM python
WORKDIR /app
RUN pip install streamlit psycopg2-binary google-cloud-aiplatform -q
COPY simple-app.py /app
ENV Matt="It's working"
EXPOSE 9000
CMD ["streamlit", "run", "simple-app.py", "--server.address", "0.0.0.0", "--server.port", "9000"]
