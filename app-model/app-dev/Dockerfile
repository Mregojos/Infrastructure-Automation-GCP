FROM python
COPY requirement.txt .
RUN pip install -U -r requirement.txt -q
WORKDIR /app
COPY . /app
# ENV DBNAME="matt" USER="matt" HOST="" DBPORT="5000" DBPASSWORD="password" PROJECT_NAME="matt-0706" 
EXPOSE 9000
CMD ["streamlit", "run", "app-three.py", "--server.address", "0.0.0.0", "--server.port", "9000"]
