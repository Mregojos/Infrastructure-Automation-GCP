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
                   layout="wide",
                   menu_items={
                       'About':"# Matt Cloud Tech"})

# Title
st.title("Pre-trained Model Deployment")
# Columns
columna, columnb = st.columns(2)
#----------Agent Section----------#

#----------Vertex AI----------#
with columna:
    agent = st.checkbox(' :computer: Agent (Talk to my Intelligent Assistant :technologist:)')
    # agent = st.toggle(' :computer: Agent (Talk to my Intelligent Assistant :technologist:)')
    if agent:
        vertexai.init(project=PROJECT_NAME, location="us-central1")
        parameters = {
            "candidate_count": 1,
            "max_output_tokens": 1024,
            "temperature": 0.2,
            "top_p": 0.8,
            "top_k": 40
        }
        model = TextGenerationModel.from_pretrained("text-bison")

        # response = model.predict(
        #    """Hi""",
        #    **parameters
        # )
        # st.write(f"Response from Model: {response.text}")

        #----------End of Vertex AI----------#
        import time
        st.header(":computer: Agent ",divider="rainbow")
        st.caption("### Chat with my agent")
        st.write(f":violet[Your chat will be stored in a database, use the same name to see your past conversations.]")
        st.caption(":warning: :red[Do not add sensitive data.]")

        # Variable
        database_name = DBNAME
        # Connect to a database
        con = psycopg2.connect(f"""
                               dbname={DBNAME}
                               user={USER}
                               host={HOST}
                               port={DBPORT}
                               password={DBPASSWORD}
                               """)
        cur = con.cursor()
        # Create a table if not exists
        cur.execute("CREATE TABLE IF NOT EXISTS chats(id serial PRIMARY KEY, name varchar, prompt varchar, output varchar, time varchar)")
        con.commit()

        # Prompt
        input_name = st.text_input("Your Name:")
        agent = st.toggle("**Let's go**")
        if agent:
            st.write(f"Your name for this chat is :blue[{input_name}]")
            prompt = st.chat_input("Talk to my agent")
            if prompt:
                time = time.strftime("Date: %Y-%m-%d | Time: %H:%M:%S UTC")
                message = st.chat_message("user")
                message.write(f":blue[{input_name}]: {prompt}")
                message.caption(f"{time}")
                message = st.chat_message("assistant")
                response = model.predict(prompt,
                    **parameters
                )
                output = response.text
                message.write(output)
                message.caption(f"{time}")
                st.divider()

                ### Insert into a database
                SQL = "INSERT INTO chats (name, prompt, output, time) VALUES(%s, %s, %s, %s);"
                data = (input_name, prompt, output, time)
                cur.execute(SQL, data)
                con.commit()


            with st.expander(f"See Previous Conversation for {input_name}"):
                cur.execute(f"""
                            SELECT * 
                            FROM chats
                            WHERE name='{input_name}'
                            ORDER BY time ASC
                            """)
                for id, name, prompt, output, time in cur.fetchall():
                    message = st.chat_message("user")
                    message.write(f":blue[{name}]: {prompt}")
                    message.caption(f"{time}")
                    message = st.chat_message("assistant")
                    message.write(output)
                    message.caption(f"{time}")
        # Close Connection
        cur.close()
        con.close()
    #----------End of Agent Section----------#

#----------Notepad Section----------#
with columnb:
    with st.expander(' :pencil: Notepad'):
        st.header(" :pencil: Notepad",divider="rainbow")
        st.caption("""
                    Add your thoughts here. It will be stored in a database. \n
                    :warning: :red[Do not add sensitive data.]
                    """)
        # Connect to a database
        con = psycopg2.connect(f"""
                               dbname={DBNAME}
                               user={USER}
                               host={HOST}
                               port={DBPORT}
                               password={DBPASSWORD}
                               """)
        cur = con.cursor()

        # Create a table if not exists
        cur.execute("CREATE TABLE IF NOT EXISTS notes(id serial PRIMARY KEY, name varchar, header varchar, note varchar, time varchar)")
        con.commit()

        # Inputs
        name = st.text_input("Your Name")
        header = st.text_input("Header")
        note = st.text_area("Note")
        if st.button("Add a note"):
            time = time.strftime("Date: %Y-%m-%d | Time: %H:%M:%S UTC")
            st.write(f""" \n
                    ##### :pencil: {header} \n
                    #### {note} \n
                    :man: {name} \n""")
            st.caption(f":watch: {time}")
            st.success("Successfully Added.")
            # st.balloons()
            ### Insert into adatabase
            SQL = "INSERT INTO notes (name, header, note, time) VALUES(%s, %s, %s, %s);"
            data = (name, header, note, time)
            cur.execute(SQL, data)
            con.commit()

        # Previous Notes 
        st.divider()
        notes = st.checkbox("See previous notes")
        if notes:
            st.write("### **:gray[Previous Notes]**")
            cur.execute("""
                        SELECT * 
                        FROM notes
                        ORDER BY time DESC
                        """)
            for id, name, header, note, time in cur.fetchall():
                st.write(f""" \n
                        ##### :pencil: {header} \n
                        #### {note} \n
                        :man: {name} \n""")
                st.caption(f":watch: {time}")

                modify = st.toggle(f"Edit or Delete (ID #: {id})")
                if modify:
                    name = st.text_input(f"Your Name (ID #: {id})", name)
                    header = st.text_input(f"Header (ID #: {id})", header)
                    note = st.text_area(f"Note (ID #: {id})", note)
                    if st.button(f"UPDATE ID #: {id}"):
                        SQL = " UPDATE notes SET id=%s, name=%s, header=%s, note=%s WHERE id = %s"
                        data = (id, name, header, note, id)
                        cur.execute(SQL, data)
                        con.commit()
                        st.success("Successfully Edited.")
                        st.button(":blue[Done]")
                    if st.button(f"DELETE ID #: {id}"):
                        cur.execute(f"DELETE FROM notes WHERE id = {id}")
                        # SQL = "DELETE FROM notes WHERE id = <...>"
                        # data = (id)
                        # cur.execute(SQL, data)
                        con.commit()
                        st.success("Successfully Deleted.")
                        st.button(":blue[Done]")
                st.subheader("",divider="gray")

        # Close Connection
        cur.close()
        con.close()
    #----------End of Notepad Section----------#

# Close Connection
cur.close()
con.close()