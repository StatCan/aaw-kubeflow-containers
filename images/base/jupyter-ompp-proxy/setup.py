import setuptools

setuptools.setup(
    name="jupyter-ompp-proxy",
    version='0.0.1',
    url="https://github.com/StatCan/jupyter-ompp-proxy",
    author="Her Majesty The Queen In Right of Canada",
    description="Jupyter extension to proxy OpenM++ webui",
    packages=setuptools.find_packages(),
	keywords=['SAS'],
	classifiers=['Framework :: Jupyter'],
    install_requires=[
        'jupyter-server-proxy>=3.2.0'
    ],
    entry_points={
        'jupyter_serverproxy_servers': [
            'ompp = jupyter_ompp_proxy:setup_ompp'
        ]
    },
    # package_data={
    #     'jupyter_sasstudio_proxy': ['icons/sasstudio.svg'],
    # },
)
