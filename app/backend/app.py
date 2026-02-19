from flask import Flask
app = Flask(__name__)

@app.route("/")
def home():
    return {"message": "Backend API Running - Hackathon"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

