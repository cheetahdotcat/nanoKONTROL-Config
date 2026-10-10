.PHONY: run sync lock clean

run:
	uv run nanoKONTROL.py

sync:
	uv sync

lock:
	uv lock --upgrade

clean:
	rm -rf .venv __pycache__
