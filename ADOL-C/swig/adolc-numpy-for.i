/*----------------------------------------------------------------------------
 ADOL-C -- Automatic Differentiation by Overloading in C++
 File:     adolc-numpy-for.i
 Revision: $Id$
 Contents: Provides all NumPY forward interfaces of ADOL-C.
 
 Copyright (c) Kshitij Kulshreshtha

 This file is part of ADOL-C. This software is provided as open source.
 Any use, reproduction, or distribution of the software constitutes 
 recipient's acceptance of the terms of the accompanying license file.  
 
----------------------------------------------------------------------------*/

%ignore forward;
%rename (forward) npy_forward;
%ignore zos_forward;
%rename (zos_forward) npy_zos_forward;
%ignore fos_forward;
%rename (fos_forward) npy_fos_forward;
%ignore hos_forward;
%rename (hos_forward) npy_hos_forward;
%ignore fov_forward;
%rename (fov_forward) npy_fov_forward;
%ignore hov_forward;
%rename (hov_forward) npy_hov_forward;
%ignore hov_wk_forward;
%rename (hov_wk_forward) npy_hov_wk_forward;

%rename (int_forward_safe) npy_int_forward_safe;
%rename (int_forward_tight) npy_int_forward_tight;
%rename (indopro_forward_safe) npy_indopro_forward_safe;
%rename (indopro_forward_tight) npy_indopro_forward_tight;
%rename (nonl_ind_forward_safe) npy_nonl_ind_forward_safe;
%rename (nonl_ind_forward_tight) npy_nonl_ind_forward_tight;


%apply (double** ARGOUTVIEWM_ARRAY1, int* DIM1) 
       {(double** y, int* d2),
        (double** y, int* m1),
        (double** y, int* m2),
        (double** yp, int* m3)};
%apply (double* IN_ARRAY1, int DIM1) 
       {(double* x, int n1),
        (double* x, int n0),
        (double* xp, int n2)};
%apply (double* IN_ARRAY2, int DIM1, int DIM2) 
       {(double* X, int n1, int d1),
        (double* X, int n2, int p2)};
%apply (double** ARGOUTVIEWM_ARRAY2, int* DIM1, int* DIM2) 
       {(double** Y, int* m2, int* d2),
        (double** Y, int* m3, int* p3)};
%apply (double* IN_ARRAY3, int DIM1, int DIM2, int DIM3) 
       {(double* X, int n2, int p2, int d2)};
%apply (double** ARGOUTVIEWM_ARRAY3, int* DIM1, int* DIM2, int* DIM3) 
       {(double** Y, int* m3, int* p3, int* d3)};
%apply (int* IN_ARRAY1, int DIM1) 
       {(int* ndim, int n0)};

%exception {
    $action
    if (PyErr_Occurred()) SWIG_fail;
}
%inline %{
    void npy_forward(short t, int m, int n, int d, int keep, double* X, int n1, int d1, double** Y, int* m2, int* d2) {
        if (n1 != n || d1 != d+1) {
            PyErr_Format(PyExc_ValueError,
                         "Array lengths don't match expected dimensions"
                         "\nExpected shapes (%d,%d)" ,n,d
                );
            return;
        } else {
            *m2 = m;
            *d2 = d+1;
            *Y = (double*)malloc((*m2)*(*d2)*sizeof(double));
            char *memory = (char*)malloc( (n1 + (*m2)) * sizeof(double*) );
            char *tmp = memory;
            double **Xp, **Yp;
            int ret;
            tmp = populate_dpp_with_contigdata(&Xp,tmp,n1,d1, X);
            tmp = populate_dpp_with_contigdata(&Yp,tmp,*m2,*d2, *Y);
            ret = forward(t,m,n,d,keep,Xp,Yp);
            free(memory);
            return;
        }
    }
    void npy_forward(short t, int m, int n, int d, int keep, double* X, int n1, int d1, double** y, int* d2) {
        if (n1 != n || d1 != d+1) {
            PyErr_Format(PyExc_ValueError,
                         "Array lengths don't match expected dimensions"
                         "\nExpected shapes (%d,%d)",n,d+1
                );
            return;
        } else {
            *d2 = d+1;
            *y = (double*) malloc((*d2)*sizeof(double));
            char *memory = (char*)malloc( n1 * sizeof(double*) );
            char *tmp = memory;
            double **Xp;
            int ret;
            tmp = populate_dpp_with_contigdata(&Xp,tmp,n1,d1, X);
            ret = forward(t,m,n,d,keep,Xp,*y);
            free(memory);
            return;
        }
    }
    void npy_forward(short t, int m, int n, int d, int keep, double* x, int n1, double** y, int* m2) {
        if (n1 != n) {
            PyErr_Format(PyExc_ValueError,
                         "Array lengths don't match expected dimensions"
                         "\nExpected shapes (%d,)",n
                );
            return;
        } else {
            int ret;
            *m2 = m;
            *y = (double*) malloc((*m2)*sizeof(double));
            ret = forward(t,m,n,d,keep,x,*y);
            return;
        }
    }
    void npy_forward(short t, int m, int n, int keep, double* x, int n1, double** y, int* m2) {
        if (n1 != n) {
            PyErr_Format(PyExc_ValueError,
                         "Array lengths don't match expected dimensions"
                         "\nExpected shapes (%d,)",n
                );
            return;
        } else {
            int ret;
            *m2 = m;
            *y = (double*) malloc((*m2)*sizeof(double));
            ret = forward(t,m,n,keep,x,*y);
            return;
        }
    }
    void npy_forward(short t, int m, int n, int d, int p, double* x, int n1, double* X, int n2, int p2, int d2, double** y, int* m2, double** Y, int* m3, int* p3, int* d3) {
        if (n1 != n || n2 != n || d2 != d || p2 != p) {
            PyErr_Format(PyExc_ValueError,
                         "Array lengths don't match expected dimensions"
                         "\nExpected shapes (%d,), (%d,%d,%d)",n,n,p,d
                );
            return;
        } else {
            *m2 = m;
            *m3 = m;
            *p3 = p;
            *d3 = d;
            *y = (double*)malloc((*m2)*sizeof(double));
            *Y = (double*)malloc((*m3)*(*p3)*(*d3)*sizeof(double));
            char *memory = (char*) malloc( (n2 + (*m3)) * sizeof(double**) + ((n2*p2) + ((*m3) *(*p3)))*sizeof(double*));
            char *tmp = memory;
            double ***Xp, ***Yp;
            int ret;
            tmp = populate_dppp_with_contigdata(&Xp,tmp,n2,p2,d2, X);
            tmp = populate_dppp_with_contigdata(&Yp,tmp,*m3,*p3,*d3, *Y);
            ret = forward(t,m,n,d,p,x,Xp,*y,Yp);
            free(memory);
            return;
        }
    }
    void npy_forward(short t, int m, int n, int p, double* x, int n1, double* X, int n2, int p2, double** y, int* m2, double** Y, int* m3, int* p3) {
        if (n1 != n || n2 != n || p2 != p) {
            PyErr_Format(PyExc_ValueError,
                         "Array lengths don't match expected dimensions"
                         "\nExpected shapes (%d,), (%d,%d)",n,n,p
                );
            return;
        } else {
            *m2 = m;
            *m3 = m;
            *p3 = p;            
            *y = (double*)malloc((*m2)*sizeof(double));
            *Y = (double*)malloc((*m3)*(*p3)*sizeof(double));
            char *memory = (char*) malloc( (n2 + (*m3)) * sizeof(double*) );
            char *tmp = memory;
            double **Xp, **Yp;
            int ret;
            tmp = populate_dpp_with_contigdata(&Xp,tmp,n2,p2, X);
            tmp = populate_dpp_with_contigdata(&Yp,tmp,*m3,*p3, *Y);
            ret = forward(t,m,n,p,x,Xp,*y,Yp);
            free(memory);
            return;
        }
    }
#ifdef __cplusplus
extern "C" {
#endif
    void npy_zos_forward(short t, int m, int n, int keep, double* x, int n1, double** y, int* m2) {
        if (n1 != n) {
            PyErr_Format(PyExc_ValueError,
                         "Array lengths don't match expected dimensions"
                         "\nExpected shapes (%d,)",n
                );
            return;
        } else {
            int ret;
            *m2 = m;
            *y = (double*)malloc((*m2)*sizeof(double));
            ret = zos_forward(t,m,n,keep,x,*y);
            return;
        }
    }
    void npy_fos_forward(short t, int m, int n, int keep, double* x, int n1, double* xp, int n2, double** y, int* m2, double** yp, int* m3) {
        if (n1 != n || n2 != n) {
            PyErr_Format(PyExc_ValueError,
                         "Array lengths don't match expected dimensions"
                         "\nExpected shapes (%d,), (%d,)",n,n
                );
            return;
        } else {
            int ret;
            *m2 = m;
            *m3 = m;
            *y = (double*)malloc((*m2)*sizeof(double));
            *yp = (double*)malloc((*m3)*sizeof(double));
            ret = fos_forward(t,m,n,keep,x,xp,*y,*yp);
            return;
        }
    }
    void npy_fov_forward(short t, int m, int n, int p, double* x, int n1, double* X, int n2, int p2, double** y, int* m2, double** Y, int* m3, int* p3) {
        if (n1 != n || n2 != n || p2 != p) {
            PyErr_Format(PyExc_ValueError,
                         "Array lengths don't match expected dimensions"
                         "\nExpected shapes (%d,), (%d,%d)",n,n,p
                );
            return;
        } else {
            *m2 = m;
            *m3 = m;
            *p3 = p;
            *y = (double*)malloc((*m2)*sizeof(double));
            *Y = (double*)malloc((*m3)*(*p3)*sizeof(double));
            char *memory = (char*)malloc((n2 + (*m3)) * sizeof(double*));
            char *tmp = memory;
            double **Xp, **Yp;
            int ret;
            tmp = populate_dpp_with_contigdata(&Xp,tmp,n2,p2, X);
            tmp = populate_dpp_with_contigdata(&Yp,tmp,*m3,*p3, *Y);
            ret = fov_forward(t,m,n,p,x,Xp,*y,Yp);
            free(memory);
            return;
        }
    }
    void npy_hos_forward(short t, int m, int n, int d, int keep, double* x, int n0, double* X, int n1, int d1, double** y, int* m1, double** Y, int* m2, int* d2) {
        if (n0 != n || n1 != n || d1 != d) {
            PyErr_Format(PyExc_ValueError,
                         "Array lengths don't match expected dimensions"
                         "\nExpected shapes (%d,), (%d,%d)",n,n,d
                );
            return;
        } else {
            *m1 = m;
            *m2 = m;
            *d2 = d;
            *y = (double*)malloc((*m1)*sizeof(double));
            *Y = (double*)malloc((*m2)*(*d2)*sizeof(double));
            char *memory = (char*)malloc((n1 + (*m2)) * sizeof(double*));
            char *tmp = memory;
            double **Xp, **Yp;
            int ret;
            tmp = populate_dpp_with_contigdata(&Xp,tmp,n1,d1, X);
            tmp = populate_dpp_with_contigdata(&Yp,tmp,*m2,*d2, *Y);
            ret = hos_forward(t,m,n,d,keep,x,Xp,*y,Yp);
            free(memory);
            return;
        }
    }
    void npy_hov_forward(short t, int m, int n, int d, int p, double* x, int n1, double* X, int n2, int p2, int d2, double** y, int* m2, double** Y, int* m3, int* p3, int* d3) {
        if (n1 != n || n2 != n || d2 != d || p2 != p) {
            PyErr_Format(PyExc_ValueError,
                         "Array lengths don't match expected dimensions"
                         "\nExpected shapes (%d,), (%d,%d,%d)",n,n,p,d
                );
            return;
        } else {
            *m2 = m;
            *m3 = m;
            *p3 = p;
            *d3 = d;
            *y = (double*)malloc((*m2)*sizeof(double));
            *Y = (double*)malloc((*m3)*(*p3)*(*d3)*sizeof(double));
            char *memory = (char*)malloc((n2 + (*m3)) * sizeof(double**) + (n2*p2 + (*m3)*(*p3)) * sizeof(double*) );
            char *tmp = memory;
            double ***Xp, ***Yp;
            int ret;
            tmp = populate_dppp_with_contigdata(&Xp,tmp,n2,p2,d2, X);
            tmp = populate_dppp_with_contigdata(&Yp,tmp,*m3,*p3,*d3, *Y);
            ret = hov_forward(t,m,n,d,p,x,Xp,*y,Yp);
            free(memory);
            return;
        }
    }
    void npy_hov_wk_forward(short t, int m, int n, int d, int p, int keep, double* x, int n1, double* X, int n2, int p2, int d2, double** y, int* m2, double** Y, int* m3, int* p3, int* d3) {
        if (n1 != n || n2 != n || d2 != d || p2 != p) {
            PyErr_Format(PyExc_ValueError,
                         "Array lengths don't match expected dimensions"
                         "\nExpected shapes (%d,), (%d,%d,%d)",n,n,p,d
                );
            return;
        } else {
            *m2 = m;
            *m3 = m;
            *p3 = p;
            *d3 = d;
            *y = (double*)malloc((*m2)*sizeof(double));
            *Y = (double*)malloc((*m3)*(*p3)*(*d3)*sizeof(double));
            char *memory = (char*)malloc((n2 + (*m3)) * sizeof(double**) + (n2*p2 + (*m3)*(*p3)) * sizeof(double*) );
            char *tmp = memory;
            double ***Xp, ***Yp;
            int ret;
            tmp = populate_dppp_with_contigdata(&Xp,tmp,n2,p2,d2, X);
            tmp = populate_dppp_with_contigdata(&Yp,tmp,*m3,*p3,*d3, *Y);
            ret = hov_wk_forward(t,m,n,d,p,keep,x,Xp,*y,Yp);
            free(memory);
            return;
        }
    }
#ifdef __cplusplus
}
#endif

%}
%clear (double* X, int n1, int d1);
%clear (double* Y, int m2, int d2);
%clear (double* y, int d2);
%clear (double* x, int n0);
%clear (double* x, int n1);
%clear (double* xp, int n2);
%clear (double* y, int m1);
%clear (double* y, int m2);
%clear (double* yp, int m3);
%clear (double* X, int n2, int p2, int d2);
%clear (double* Y, int m3, int p3, int d3);
%clear (double* X, int n2, int p2);
%clear (double* Y, int m3, int p3);
%clear (int* ndim, int n0);
%exception ;
