from flask import Flask, render_template, request, url_for, flash, redirect
from Crochemar_final_project.mastermind.mastermind_game import MastermindGame
import numpy as np
import matplotlib.pyplot as plt
import os
#We import different packages
app = Flask(__name__)
app.secret_key = "replace-this-with-a-random-string"
#We set up the environment for Flask
@app.route("/", methods=["GET", "POST"]) #It allows us to create a route for the app
def home():
    if request.method == "POST":
        #It will read and cast form values
        n_colors = int(request.form["n_colors"])
        code_length = int(request.form["code_length"])
        allow_repetition = request.form["allow_repetition"] == "true"
        mode = request.form["mode"]
        n_runs = int(request.form["n_runs"])

        if not allow_repetition and code_length > n_colors: #To create a way to get an error
            flash(
                f"With repetition disabled, code length ({code_length}) "
                f"cannot exceed number of colors ({n_colors}).",
                "error"
            )
            return redirect(url_for("home"))

        game = MastermindGame(
            n_colors=n_colors,
            code_length=code_length,
            allow_repetition=allow_repetition,
            mode=mode
        )
        results = game.simulate_multiple_games(n_runs)

        mean_attempts = np.mean(results)
        std_attempts = np.std(results)
        max_attempts = np.max(results) #We stock the results for the game

        save_path = os.path.join(app.root_path, "static", "hist.png") #To create an absolute path and avoid getting an error
        plt.figure()
        plt.hist(results, bins=range(min(results), max(results) + 2))
        plt.xlabel("Attempts")
        plt.ylabel("Frequency")
        plt.title("Distribution of Attempts")
        plt.tight_layout()
        plt.savefig(save_path)
        plt.close()
        #We get a histogram to show to the player
        return render_template(
            "results.html",
            n_runs=n_runs,
            mean_attempts=mean_attempts,
            std_attempts=std_attempts,
            max_attempts=max_attempts
        )


    return render_template("index.html")

if __name__ == "__main__":
    app.run(debug=True)