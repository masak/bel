from runner import Runner
import sys

if __name__ == "__main__":
    runner = Runner()
    while True:
        try:
            source = input("> ")
        except EOFError as e:
            break

        try:
            output = runner.run(source)
            if output is not None:
                print(output)
        except ValueError as e:
            print("Error: invalid input", file=sys.stderr)
