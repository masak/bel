class Runner:
    def run(self, source):
        if source.startswith("'"):
            return source[1:]
        elif source == "":
            return ""
        else:
            raise ValueError(f"invalid input: {source}")
