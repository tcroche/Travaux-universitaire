import numpy as np
import random
#We import the packages

class MastermindGame:
    def __init__(self, n_colors, code_length, allow_repetition=True, mode='standard', color_names= None):
        self.n_colors = n_colors
        self.code_length = code_length
        self.allow_repetition = allow_repetition
        self.mode = mode
        if color_names is not None:
            if len(color_names) != n_colors:
                raise ValueError("color_names length must equal n_colors")
            self.color_names = color_names
        else:
            # default list—slice to n_colors
            defaults = ['Red', 'Green', 'Blue', 'Yellow', 'Orange', 'Purple', 'Cyan', 'Magenta']
            self.color_names = defaults[:n_colors]
        self.secret_code = None
        self.history = [] #Allow us to keep the list of (guess, feedback) tuples

    def generate_secret_code(self):
        """
        Draws a random secret code according to settings
        and stores it in self.secret_code as a NumPy array.
        """
        if self.allow_repetition:
            # allow repeats: draw each position independently
            nums = np.random.randint(0, self.n_colors, size=self.code_length)
        else:
            # no repeats: sample without replacement
            nums = np.random.choice(
                np.arange(self.n_colors),
                size=self.code_length,
                replace=False
            )
        self.secret_code = [self.color_names[i] for i in nums]
        return self.secret_code

    def evaluate_guess(self, guess):
        """
        In ‘standard’ mode returns (black_pegs, white_pegs);
        in ‘beginner’ mode returns a list of length code_length with
        values 'black', 'white', or None for each position.
        """
        if self.secret_code is None:
            raise ValueError("Secret code not generated yet.")
        if len(guess) != self.code_length:
            raise ValueError(f"Guess must have {self.code_length} colors.")
        # Validate colors
        for color in guess:
            if color not in self.color_names:
                raise ValueError(f"Invalid color in guess: {color!r}")

        from collections import Counter
        sec_cnt = Counter(self.secret_code)
        gue_cnt = Counter(guess)
        # total matches per color
        total_per_color = {
            c: min(sec_cnt[c], gue_cnt[c]) for c in sec_cnt
        }

        if self.mode == 'standard':
            # Blacks
            black = sum(s == g for s, g in zip(self.secret_code, guess))
            # Whites = total matches − blacks
            white = sum(total_per_color.values()) - black
            return black, white

        elif self.mode == 'beginner':
            # prepare feedback slots
            feedback = [None] * self.code_length
            # 1) Assign blacks
            for i, (s, g) in enumerate(zip(self.secret_code, guess)):
                if s == g:
                    feedback[i] = 'black'
                    total_per_color[g] -= 1
            # 2) Assign whites left-to-right
            for i, g in enumerate(guess):
                if feedback[i] is None and total_per_color.get(g, 0) > 0:
                    feedback[i] = 'white'
                    total_per_color[g] -= 1
            return feedback

        else:
            raise ValueError(f"Unknown mode: {self.mode!r}")

    def make_guess(self, guess):
        """
        Process one guess: evaluate feedback, record it, and
        return the feedback.
        """
        fb = self.evaluate_guess(guess)
        # record the guess + feedback
        self.history.append((guess, fb))
        return fb

    @staticmethod
    def _score_codes(code, guess):
        """
        Given two lists of colors (code vs guess), return (black, white)
        exactly as in standard mode.
        """
        from collections import Counter

        # 1) blacks
        black = sum(s == g for s, g in zip(code, guess))
        # 2) total matches per color
        sec_cnt = Counter(code)
        gue_cnt = Counter(guess)
        total = sum(min(sec_cnt[c], gue_cnt[c]) for c in sec_cnt)
        white = total - black
        return black, white

    def simulate_one_game(self):
        """
        Plays one game by:
        - generating a fresh secret code,
        - initializing the candidate pool,
        - looping random guesses consistent with all feedback,
        until the code is found.
        Returns the number of attempts used.
        """
        # reset history & secret and pool
        self.history = []
        self.generate_secret_code()
        self._init_candidate_pool()

        # loop until solved
        while True:
            # pick a random candidate
            guess = random.choice(self.candidate_pool)
            # evaluate & record
            fb = self.make_guess(guess)
            #narrow down pool to those matching the feedback
            self.candidate_pool = [
                c for c in self.candidate_pool
                if self._score_codes(c, guess) == fb
            ]
            #stop if solved
            if self.is_solved:
                break

        return self.attempts

    def simulate_multiple_games(self, n_runs):
        """
        Run simulate_one_game() n_runs times and
        return a list of attempt counts.
        """
        attempts = []
        for _ in range(n_runs):
            attempts.append(self.simulate_one_game())
        return attempts


    @property
    def attempts(self):
        """Number of guesses made so far."""
        return len(self.history)

    @property
    def is_solved(self):
        """
        True if last feedback is a full match:
        - in standard mode: black == code_length
        - in beginner mode: all 'black'
        """
        if not self.history:
            return False
        last_fb = self.history[-1][1]
        if self.mode == 'standard':
            black, _ = last_fb
            return black == self.code_length
        else:  # beginner
            return all(peg == 'black' for peg in last_fb)

    def _init_candidate_pool(self):
        """
        Build self.candidate_pool = list of all possible codes (lists of color-names)
        given n_colors, code_length, and allow_repetition.
        """
        from itertools import product, permutations

        if self.allow_repetition:
            combos = product(self.color_names, repeat=self.code_length)
        else:
            combos = permutations(self.color_names, self.code_length)

        # store as list of lists
        self.candidate_pool = [list(c) for c in combos]