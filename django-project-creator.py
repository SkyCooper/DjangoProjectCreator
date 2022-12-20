from virtualenv import cli_run
import urllib.request
from subprocess import check_output, run, DEVNULL
import sys
import os
import logging


class bcolors:
    HEADER = "\033[95m"
    OKBLUE = "\033[94m"
    OKCYAN = "\033[96m"
    OKGREEN = "\033[92m"
    WARNING = "\033[93m"
    FAIL = "\033[91m"
    ENDC = "\033[0m"
    BOLD = "\033[1m"
    UNDERLINE = "\033[4m"


def pip_install(package: str):
    check_output([sys.executable, "-m", "pip", "install", package])


def main():
    windows = True if os.name == "nt" else False
    logfile = f'{os.path.expanduser("~")}/django-project-creator.log'
    logging.basicConfig(
        filename=logfile,
        filemode="a",
        format="%(asctime)s,%(msecs)d %(name)s %(levelname)s %(message)s",
        datefmt="%H:%M:%S",
        level=logging.DEBUG,
    )
    logger = logging.getLogger("django-project-creator")

    logger.info("Starting Django Project Creator")
    print(
        f"{bcolors.BOLD}{bcolors.HEADER}Starting Django Project Creator...{bcolors.ENDC}\n"
    )

    project_name = ""
    try:
        project_name = sys.argv[1]
        logger.info(f"Project name: {project_name}\n")
    except IndexError as ex:
        logger.info('No project name was provided. Using "django-project".')
        print(
            f'{bcolors.WARNING}No project name was provided. Using "django-project".{bcolors.ENDC}\n'
        )
        project_name = "django-project"

    if windows:
        os.system("color")

    try:
        os.mkdir(project_name)
        print(
            f"{bcolors.OKGREEN}Created project directory: {bcolors.BOLD}{bcolors.OKBLUE}{project_name}{bcolors.ENDC}"
        )
        logger.info(f"Created project directory: {project_name}")
    except Exception as ex:
        print(f"{bcolors.BOLD}{bcolors.FAIL}{ex}{bcolors.ENDC}")
        logger.fatal(ex)
        exit(1)
    try:
        os.chdir(project_name)
        print(
            f"{bcolors.OKGREEN}Changed active directory to project directory: {bcolors.BOLD}{bcolors.OKBLUE}{project_name}{bcolors.ENDC}"
        )
        logger.info(f"Changed active directory to project directory: {project_name}")
    except Exception as ex:
        print(f"{bcolors.BOLD}{bcolors.FAIL}{ex}{bcolors.ENDC}")
        logger.fatal(ex)
        exit(1)

    try:
        cli_run(["env"])
        print(
            f"{bcolors.OKGREEN}Created virtual environment: {bcolors.BOLD}{bcolors.OKBLUE}{project_name}/env{bcolors.ENDC}"
        )
        logger.info(f"Created virtual environment: {project_name}/env")
    except Exception as ex:
        print(f"{bcolors.BOLD}{bcolors.FAIL}{ex}{bcolors.ENDC}")
        logger.fatal(ex)
        exit(1)
    exit(0)

    # Rest is not working
    # TODO figure out how to activate venv programmatically.
    try:
        if windows:
            run([".\\env\\Scripts\\activate"], stdout=DEVNULL, check=True)
        else:
            os.system("/bin/bash ./env/bin/activate")
        print(
            f"{bcolors.OKGREEN}Activated virtual environment: {bcolors.BOLD}{bcolors.OKBLUE}{project_name}/env{bcolors.ENDC}"
        )
        logger.info(f"Activated virtual environment: {project_name}/env")
    except Exception as ex:
        print(f"{bcolors.BOLD}{bcolors.FAIL}{ex}{bcolors.ENDC}")
        logger.fatal(ex)
        exit(1)

    try:
        print(f"{bcolors.OKCYAN}Installing Django...{bcolors.ENDC}")
        pip_install("django")
        print(f"{bcolors.OKGREEN}Installed Django.{bcolors.ENDC}")
        logger.info("Installed Django.")
    except Exception as ex:
        print(f"{bcolors.BOLD}{bcolors.FAIL}{ex}{bcolors.ENDC}")
        logger.fatal(ex)
        exit(1)


if __name__ == "__main__":
    main()
