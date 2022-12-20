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
    run(f"./env/bin/python -m pip install {package}", shell=True, stdout=DEVNULL)


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

    # Rest is not working
    # TODO figure out how to activate venv programmatically.
    try:
        if windows:
            run([".\\env\\Scripts\\activate"], stdout=DEVNULL, shell=True, check=True)
        else:
            run("source ./env/bin/activate", stdout=DEVNULL, shell=True, check=True)
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

    try:
        print(f"{bcolors.OKCYAN}Creating requirements.txt...{bcolors.ENDC}")
        run("./env/bin/python -m pip freeze > requirements.txt", shell=True, check=True)
        print(f"{bcolors.OKGREEN}Created requirements.txt.{bcolors.ENDC}")
        logger.info("Created requirements.txt.")
        with open("requirements.txt", "r") as reqs:
            print(
                f"\n{bcolors.BOLD}{bcolors.UNDERLINE}{bcolors.HEADER}Required packages:{bcolors.ENDC}\n"
            )
            print(f"{bcolors.HEADER}{reqs.read()}{bcolors.ENDC}")
    except Exception as ex:
        print(f"{bcolors.BOLD}{bcolors.FAIL}{ex}{bcolors.ENDC}")
        logger.fatal(ex)
        exit(1)
    try:
        print(f"{bcolors.OKCYAN}Creating Django project 'main'...{bcolors.ENDC}")
        run("django-admin startproject main .", shell=True, check=True)
        print(f"{bcolors.OKGREEN}Created Django project.{bcolors.ENDC}")
        logger.info("Created Django project.")
    except Exception as ex:
        print(f"{bcolors.BOLD}{bcolors.FAIL}{ex}{bcolors.ENDC}")
        logger.fatal(ex)
        exit(1)

    try:
        print(f"{bcolors.OKCYAN}Starting Django migration...{bcolors.ENDC}")
        run("./env/bin/python manage.py migrate", shell=True, check=True)
        print(f"{bcolors.OKGREEN}Django migration is successful.{bcolors.ENDC}")
        logger.info("Django migration is successful.")
    except Exception as ex:
        print(f"{bcolors.BOLD}{bcolors.FAIL}{ex}{bcolors.ENDC}")
        logger.fatal(ex)
        exit(1)

    try:
        print(f"{bcolors.OKCYAN}Creating superuser...{bcolors.ENDC}")
        run("./env/bin/python manage.py createsuperuser", shell=True, check=True)
        print(f"{bcolors.OKGREEN}Created superuser.{bcolors.ENDC}")
        logger.info("Created superuser.")
    except Exception as ex:
        print(f"{bcolors.BOLD}{bcolors.FAIL}{ex}{bcolors.ENDC}")
        logger.fatal(ex)
        exit(1)

    try:
        gitignore_url = "https://www.toptal.com/developers/gitignore/api/django"
        opener = urllib.request.build_opener()
        opener.addheaders = [
            (
                "User-Agent",
                "Mozilla/5.0 (X11; Linux x86_64; rv:108.0) Gecko/20100101 Firefox/108.0",
            )
        ]
        with opener.open(gitignore_url) as url_file:
            url_content = url_file.read()
        print(
            f"{bcolors.OKCYAN}Downloading .gitignore for Django project...{bcolors.ENDC}"
        )
        with opener.open(gitignore_url) as url_file:
            url_content = url_file.read()
            with open(".gitignore", "wb") as gitignore:
                gitignore.write(url_content)

        print(f"{bcolors.OKGREEN}Downloaded .gitignore successfully.{bcolors.ENDC}")
        logger.info("Downloaded .gitignore successfully.")
    except Exception as ex:
        print(f"{bcolors.BOLD}{bcolors.FAIL}{ex}{bcolors.ENDC}")
        logger.fatal(ex)
        exit(1)
    print(f"\n{bcolors.BOLD}{bcolors.OKGREEN}Created Django project.{bcolors.ENDC}\n")
    print(
        f"{bcolors.OKBLUE}Use following commands to start your project:{bcolors.ENDC}\n"
    )
    print(f"{bcolors.BOLD}{bcolors.OKCYAN}cd {project_name}{bcolors.ENDC}")
    print(f"{bcolors.BOLD}{bcolors.OKCYAN}source env/bin/activate{bcolors.ENDC}")
    exit(0)


if __name__ == "__main__":
    main()
