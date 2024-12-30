import setuptools

setuptools.setup(
    name="jupyter-sasstudio-proxy",
    version='0.0.1',
    url="https://github.com/StatCan/jupyter-sasstudio-proxy",
    author="Her Majesty The Queen In Right of Canada",
    description="Jupyter extension to proxy SASStudio",
    packages=setuptools.find_packages(),
	keywords=['SAS'],
	classifiers=['Framework :: Jupyter'],
    install_requires=[
        'jupyter-server-proxy>=3.2.0'
    ],
    entry_points={
        'jupyter_serverproxy_servers': [
            'sasstudio = jupyter_sasstudio_proxy:setup_sasstudio'
        ]
    },
    # package_data={
    #     'jupyter_sasstudio_proxy': ['icons/sasstudio.svg'],
    # },
)
