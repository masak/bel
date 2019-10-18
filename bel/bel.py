if __name__ == "__main__":
    eof = False
    while not eof:
        try:
            input("> ")
        except EOFError as e:
            eof = True
