import setuptools

setuptools.setup(
    name='mytools',
    version='0.1.0',
    author="Li Jing",
    author_email="lijing@inetlinux.com",
    description="My common package",
    url="https://dev.inetlinux.com//mytools",
    packages=setuptools.find_packages(exclude=['*.pyc']),
    install_requires=['pyyaml'],
    ext_modules = [setuptools.Extension("myext", ["myext.c"])],
    license='MIT',
)
