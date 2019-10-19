class BelEvalError(Exception):
    def __init__(self, symbol):
        self.symbol = symbol

CHARCODES = set(["bel", "tab", "lf", "cr", "sp"])
SELF_EVALUATING = set(["nil", "t", "o", "apply"])

class Runner:
    def run(self, source):
        if source.startswith("'"):
            return source[1:]
        elif source.startswith("\\"):
            rest = source[1:]
            if not (len(rest) == 1 or rest in CHARCODES):
                raise BelEvalError("unknown-named-char")
            return source
        elif source in SELF_EVALUATING:
            return source
        elif source == "":
            return None
        else:
            raise ValueError(f"invalid input: {source}")
