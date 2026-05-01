from pathlib import Path


def main() -> None:
    logo_path = Path("assets/images/jhatpatlogo.png")
    if not logo_path.exists():
        raise FileNotFoundError(f"Missing logo: {logo_path}")
    print(f"Using PNG logo: {logo_path}")


if __name__ == "__main__":
    main()
