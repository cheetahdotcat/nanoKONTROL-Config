.PHONY: run sync lock appimage pyinstaller clean

run:
	uv run nanoKONTROL.py

sync:
	uv sync

lock:
	uv lock --upgrade

appimage:
	packaging/build-appimage.sh

pyinstaller:
	packaging/build-pyinstaller.sh

clean:
	rm -rf .venv __pycache__ build dist
