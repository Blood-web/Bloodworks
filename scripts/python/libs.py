## Include all of Pythons dependancies via this script.
## As modules are found missing, be sure to add them to the libraries array found below.
import subprocess

def install_libraries():
    try:
        # List of libraries to install
        libraries = [
            "adafruit-circuitpython-bundle",
            "ampy",
            "pyserial",  
            # Add more libraries as needed
        ]

        # Install each library using pip
        for lib in libraries:
            subprocess.run(["pip", "install", lib])
        
        print("Libraries installed successfully.")
    except Exception as e:
        print("Error installing libraries:", e)

if __name__ == "__main__":
    install_libraries()
