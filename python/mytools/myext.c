#include <Python.h>
#include <sys/prctl.h>

static PyObject *myext_setprocname(PyObject *self, PyObject *args)
{
    int argc;
    char **argv, *name, *rem;
    if (!PyArg_ParseTuple(args, "s", &name))
        return NULL;

    Py_GetArgcArgv(&argc, &argv);

    strncpy(argv[0], name, strlen(name));
    rem = &argv[0][strlen(name)];
    memset(rem, 0, strlen(rem));
    prctl(PR_SET_NAME, name, 0, 0, 0);

    Py_INCREF(Py_None);
    return Py_None;
}

static PyMethodDef Methods[] = {
    {"setprocname",  myext_setprocname, METH_VARARGS, "Set process name"},
    {NULL, NULL, 0, NULL}
};

PyMODINIT_FUNC initmyext(void)
{
    (void) Py_InitModule("myext", Methods);
}
