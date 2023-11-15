FROM python
RUN pip install streamlit psycopg2-binary google-cloud-aiplatform -q
WORKDIR /app
COPY . /app
ENV DBNAME="matt" USER="matt" HOST="34.28.187.13" DBPORT="5000" DBPASSWORD="password" PROJECT_NAME="matt-0706" 
EXPOSE 9000
CMD ["streamlit", "run", "app-three.py", "--server.address", "0.0.0.0", "--server.port", "9000"]
