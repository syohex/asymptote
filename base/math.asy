// Asymptote mathematics routines

real radians(real degrees)
{
  return degrees*pi/180;
}

real degrees(real radians) 
{
  return radians*180/pi;
}

int quadrant(real degrees)
{
  return floor(degrees/90) % 4;
}

// Roots of unity. 
pair zeta(int n, int k = 1)
{
  return expi(2pi*k/n);
}

real Sin(real deg) {return sin(radians(deg));}
real Cos(real deg) {return cos(radians(deg));}
real Tan(real deg) {return tan(radians(deg));}
real aSin(real x) {return degrees(asin(x));}
real aCos(real x) {return degrees(acos(x));}
real aTan(real x) {return degrees(atan(x));}
real csc(real x) {return 1/sin(x);}
real sec(real x) {return 1/cos(x);}
real cot(real x) {return tan(pi/2-x);}
real frac(real x) {return x-(int)x;}

pair exp(explicit pair z) {return exp(z.x)*expi(z.y);}
pair log(explicit pair z) {return log(abs(z))+I*angle(z);}

// Return an Nx by Ny unit square lattice with lower-left corner at (0,0).
picture grid(int Nx, int Ny, pen p=currentpen)
{
  picture pic=new picture;
  for(int i=0; i <= Nx; ++i) draw(pic,(i,0)--(i,Ny),p);
  for(int j=0; j <= Ny; ++j) draw(pic,(0,j)--(Nx,j),p);
  return pic; 
}

bool straight(path p)
{
  for(int i=0; i < length(p); ++i)
    if(!straight(p,i)) return false;
  return true;
}

bool polygon(path p)
{
  return cyclic(p) && straight(p);
}

void assertpolygon(path p)
{
  if(!polygon(p)) {
    write(p);
    abort("Polygon must be a straight cyclic path. ");
  }
}

// Returns true iff the point z lies in the region bounded by the cyclic
// polygon p.
bool inside(pair z, path p)
{
  assertpolygon(p);
  bool c=false;
  int n=length(p);
  for(int i=0; i < n; ++i) {
    pair pi=point(p,i);
    pair pj=point(p,i+1);
    if(((pi.y <= z.y && z.y < pj.y) || (pj.y <= z.y && z.y < pi.y)) &&
       z.x < pi.x+(pj.x-pi.x)*(z.y-pi.y)/(pj.y-pi.y)) c=!c;
  }
  return c;
}

// Returns true iff the line a--b intersects the cyclic polygon p.
bool intersect(pair a, pair b, path p)
{
  assertpolygon(p);
  int n=length(p);
  for(int i=0; i < n; ++i) {
    pair A=point(p,i);
    pair B=point(p,i+1);
    real de=(b.x-a.x)*(A.y-B.y)-(A.x-B.x)*(b.y-a.y);
    if(de != 0) {
      de=1/de;
      real t=((A.x-a.x)*(A.y-B.y)-(A.x-B.x)*(A.y-a.y))*de;
      real T=((b.x-a.x)*(A.y-a.y)-(A.x-a.x)*(b.y-a.y))*de;
      if(0 <= t && t <= 1 && 0 <= T && T <= 1) return true;
    }
  }
  return false;
}

// Return the intersection point of the extensions of the line segments 
// PQ and pq.
pair extension(pair P, pair Q, pair p, pair q) 
{
  pair ac=P-Q;
  pair bd=q-p;
  real det=(conj(ac)*bd).y;
  if(det == 0) return (infinity,infinity);
  return P+(conj(p-P)*bd).y*ac/det;
}

pair intersectionpoint(path a, path b)
{
  return point(a,intersect(a,b).x);
}

struct vector {
  public real x,y,z;
  void vector(real x, real y, real z) {this.x=x; this.y=y; this.z=z;}
}

void write(file out, vector v)
{
  write(out,"(");
  write(out,v.x); write(out,","); write(out,v.y); write(out,",");
  write(out,v.z);
  write(out,")");
}

void write(vector v)
{
  write(stdout,v); write(stdout,endl);
}

vector vector(real x, real y, real z)
{
  vector v=new vector;
  v.vector(x,y,z);
  return v;
}

real length(vector a)
{
  return sqrt(a.x^2+a.y^2+a.z^2);
}

vector operator - (vector a)
{
  return vector(-a.x,-a.y,-a.z);
}

vector operator + (vector a, vector b)
{
  return vector(a.x+b.x,a.y+b.y,a.z+b.z);
}

vector operator - (vector a, vector b)
{
  return vector(a.x-b.x,a.y-b.y,a.z-b.z);
}

vector operator * (vector a, real s)
{
  return vector(a.x*s,a.y*s,a.z*s);
}

vector operator * (real s,vector a)
{
  return a*s;
}

vector operator / (vector a, real s)
{
  return vector(a.x/s,a.y/s,a.z/s);
}

bool operator == (vector a, vector b) 
{
  return a.x == b.x && a.y == b.y && a.z == b.z;
}

bool operator != (vector a, vector b) 
{
  return a.x != b.x || a.y != b.y || a.z != b.z;
}

vector interp(vector a, vector b, real c)
{
  return a+c*(b-a);
}

real Dot(vector a, vector b)
{
  return a.x*b.x+a.y*b.y+a.z*b.z;
}

vector Cross(vector a, vector b)
{
  return vector(a.y*b.z-a.z*b.y,
		a.z*b.x-a.x*b.z,
		a.x*b.y-b.x*a.y);
}

// Compute normal vector to the plane defined by the first 3 vectors of p.
vector normal(vector[] p)
{
  if(p.length < 3) abort("3 vectors are required to define a plane");
  return Cross(p[1]-p[0],p[2]-p[0]);
}

vector unit(vector p)
{
  return p/length(p);
}

vector unitnormal(vector[] p)
{
  return unit(normal(p));
}

// Return the intersection time of the extension of the line segment PQ
// with the plane perpendicular to n and passing through Z.
real intersection(vector P, vector Q, vector n, vector Z)
{
  real d=n.x*Z.x+n.y*Z.y+n.z*Z.z;
  real denom=n.x*(Q.x-P.x)+n.y*(Q.y-P.y)+n.z*(Q.z-P.z);
  return denom == 0 ? infinity : (d-n.x*P.x-n.y*P.y-n.z*P.z)/denom;
}
		    
// Return any point on the intersection of the two planes with normals
// n0 and n1 passing through points P0 and P1, respectively.
// If the planes are parallel return vector(infinity,infinity,infinity).
vector intersectionpoint(vector n0, vector P0, vector n1, vector P1)
{
  real Dx=n0.y*n1.z-n1.y*n0.z;
  real Dy=n0.z*n1.x-n1.z*n0.x;
  real Dz=n0.x*n1.y-n1.x*n0.y;
  if(abs(Dx) > abs(Dy) && abs(Dx) > abs(Dz)) {
    Dx=1/Dx;
    real d0=n0.y*P0.y+n0.z*P0.z;
    real d1=n1.y*P1.y+n1.z*P1.z+n1.x*(P1.x-P0.x);
    real y=(d0*n1.z-d1*n0.z)*Dx;
    real z=(d1*n0.y-d0*n1.y)*Dx;
    return vector(P0.x,y,z);
  } else if(abs(Dy) > abs(Dz)) {
    Dy=1/Dy;
    real d0=n0.z*P0.z+n0.x*P0.x;
    real d1=n1.z*P1.z+n1.x*P1.x+n1.y*(P1.y-P0.y);
    real z=(d0*n1.x-d1*n0.x)*Dy;
    real x=(d1*n0.z-d0*n1.z)*Dy;
    return vector(x,P0.y,z);
  } else {
    if(Dz == 0) return vector(infinity,infinity,infinity);
    Dz=1/Dz;
    real d0=n0.x*P0.x+n0.y*P0.y;
    real d1=n1.x*P1.x+n1.y*P1.y+n1.z*(P1.z-P0.z);
    real x=(d0*n1.y-d1*n0.y)*Dz;
    real y=(d1*n0.x-d0*n1.x)*Dz;
    return vector(x,y,P0.z);
  }
}

// Given a real array A, return its partial (optionally dx-weighted) sums.
real[] partialsum(real[] A, real[] dx={}) 
{
  real[] B=new real[A.length];
  B[0]=0;
  if(dx.length == 0)
    for(int i=0; i < A.length; ++i) B[i+1]=B[i]+A[i];
  else
    for(int i=0; i < A.length; ++i) B[i+1]=B[i]+A[i]*dx[i];
  return B;
}

real[] zero(int n)
{
  return sequence(new real(int x){return 0;},n);
}

real[][] zero(int n, int m)
{
  real[][] M=new real[n][m];
  for(int i=0; i < n; ++i)
    M[i]=sequence(new real(int x){return 0;},m);
  return M;
}

real[][] identity(int n)
{
  real[][] m=new real[n][n];
  for(int i=0; i < n; ++i)
    m[i]=sequence(new real(int x){return x == i ? 1 : 0;},n);
  return m;
}

real[][] operator + (real[][] a, real[][] b)
{
  int n=a.length;
  real[][] m=new real[0][n];
  for(int i=0; i < n; ++i)
    m[i]=a[i]+b[i];
  return m;
}

real[][] operator - (real[][] a, real[][] b)
{
  int n=a.length;
  real[][] m=new real[0][n];
  for(int i=0; i < n; ++i)
    m[i]=a[i]-b[i];
  return m;
}

real[][] operator * (real[][] a, real[][] b)
{
  int n=a.length;
  int nb=b.length;
  int nb0=b[0].length;
  real[][] m=new real[n][nb0];
  for(int i=0; i < n; ++i) {
    real[] ai=a[i];
    real[] mi=m[i];
    if(ai.length != nb) 
      abort("Multiplication of incommensurate matrices is undefined");
    for(int j=0; j < nb0; ++j) {
      real sum;
      for(int k=0; k < nb; ++k)
	sum += ai[k]*b[k][j];
      mi[j]=sum;
    }
  }
  return m;
}

real[] operator * (real[][] a, real[] b)
{
  return transpose(a*transpose(new real[][] {b}))[0];
}

real[] operator * (real[] b, real[][] a)
{
  return (new real[][] {b}*a)[0];
}

real[][] operator * (real[][] a, real b)
{
  int n=a.length;
  real[][] m=new real[0][n];
  for(int i=0; i < n; ++i)
    m[i]=a[i]*b;
  return m;
}

real[][] operator * (real b, real[][] a)
{
  return a*b;
}

real[][] operator / (real[][] a, real b)
{
  return a*(1/b);
}

bool square2(real[][] m)
{
  return m[0].length == m.length && m[1].length == m.length;
}

bool square(real[][] m)
{
  int n=m.length;
  for(int i=0; i < n; ++i)
    if(m[i].length != n) return false;
  return true;
}

real determinant(real[][] m)
{
  int n=m.length;
  if(n == 2 && square2(m)) return m[0][0]*m[1][1]-m[0][1]*m[1][0];
  
  if(!square(m)) 
    abort("attempted to take the determinant of a nonsquare matrix");
  
  if(n != 3) abort("determinant of a general matrix is not yet implemented");
  
  return
     m[0][0]*(m[1][1]*m[2][2]-m[1][2]*m[2][1])
    -m[0][1]*(m[1][0]*m[2][2]-m[1][2]*m[2][0])
    +m[0][2]*(m[1][0]*m[2][1]-m[1][1]*m[2][0]);
}

// Solve the linear equation ax=b by Gauss-Jordan elimination, returning
// the solution x, where a is an n x n matrix and b is an n x m matrix.
// If overwrite=true, b is replaced by x.

real[][] solve(real[][] a, real[][] b, bool overwrite=false)
{
  a=copy(a);
  if(!overwrite) b=copy(b);
  int n=a.length;
  int m=b[0].length;
  
  if(n != a[0].length) abort("First matrix is not square");
  if(n != b.length) abort("Cannot solve incommensurate matrices");
	
  int[] pivot=sequence(new int(int){return 0;},n);
  
  int col=0, row=0;
  for(int i=0; i < n; ++i) {
    real big=0.0;
    for(int j=0; j < n; ++j) {
      real[] aj=abs(a[j]);
      // Search for a pivot element.
      if(find(pivot > 1) >= 0) abort("Singular matrix");
      if(pivot[j] != 1) {
	real M=max(pivot == 0 ? aj : null);
	if(M >= big) {
	  big=M;
	  row=j;
	  col=find(aj == M);
	}
      }
    }
    ++(pivot[col]);
    // Interchange rows, if needed, to put the pivot element on the diagonal.
    if(row != col) {
      real[] temp;
      temp=a[row]; a[row]=a[col]; a[col]=temp;
      temp=b[row]; b[row]=b[col]; b[col]=temp;
    }
    // Divide the pivot row by the pivot element.
    real denom=a[col][col];
    if(denom == 0.0) abort("Singular matrix");
    
    real pivinv=1.0/denom;
    a[col] *= pivinv;
    b[col] *= pivinv;
    for(int i=0; i < n; ++i) {
      // Reduce all rows except for the pivoted one.
      if(i != col) {
	real dum=a[i][col];
	a[i][col]=0.0;
	a[i] -= a[col]*dum;
	b[i] -= b[col]*dum;
      }
    }
  }
  
  return b;
}

// Solve the linear equation ax=b, returning the solution x, where a is
// an n x n matrix and b is an array of length n. 

real[] solve(real[][] a, real[] b)
{
  return transpose(solve(a,transpose(new real[][]{b}),true))[0];
}

real[][] inverse(real[][] m)
{
  int n=m.length;
  
  if(n == 2 && square2(m))
    return new real[][] {{m[1][1],-m[0][1]},{-m[1][0],m[0][0]}}/determinant(m);
  if(!square(m)) abort("attempted to invert a non-square matrix");
  
  if(n == 3) {
    return new real[][] {
      {    m[1][1]*m[2][2]-m[1][2]*m[2][1],
	  -m[0][1]*m[2][2]+m[0][2]*m[2][1],
	   m[0][1]*m[1][2]-m[0][2]*m[1][1]},	
      {   -m[1][0]*m[2][2]+m[1][2]*m[2][0],
	   m[0][0]*m[2][2]-m[0][2]*m[2][0],
	  -m[0][0]*m[1][2]+m[0][2]*m[1][0]},
      {    m[1][0]*m[2][1]-m[1][1]*m[2][0],
	  -m[0][0]*m[2][1]+m[0][1]*m[2][0],
	   m[0][0]*m[1][1]-m[0][1]*m[1][0]}
    }/determinant(m);
  }
  
  return solve(m,identity(n),true);
}

// draw the (infinite) line going through P and Q, without altering the
// size of picture pic.
void drawline(picture pic=currentpicture, pair P, pair Q, pen p=currentpen)
{
  pic.add(new void (frame f, transform t, transform, pair m, pair M) {
    // Reduce the bounds by the size of the pen.
    m -= min(p); M -= max(p);

    // Calculate the points and direction vector in the transformed space.
    pair z=t*P;
    pair v=t*Q-z;

    // Handle horizontal and vertical lines.
    if(v.x == 0) {
      if(m.x <= z.x && z.x <= M.x)
	draw(f,(z.x,m.y)--(z.x,M.y),p);
    } else if(v.y == 0) {
      if(m.y <= z.y && z.y <= M.y)
	draw(f,(m.y,z.y)--(M.x,z.y),p);
    } else {
      // Calculate the maximum and minimum t values allowed for the
      // parametric equation z + t*v
      real mx=(m.x-z.x)/v.x, Mx=(M.x-z.x)/v.x;
      real my=(m.y-z.y)/v.y, My=(M.y-z.y)/v.y;
      real tmin=max(v.x > 0 ? mx : Mx, v.y > 0 ? my : My);
      real tmax=min(v.x > 0 ? Mx : mx, v.y > 0 ? My : my);
      if(tmin <= tmax)
	draw(f,z+tmin*v--z+tmax*v,p);
    }
  });
}

real interpolate(real[] x, real[] y, real x0, int i) 
{
  int n=x.length;
  if(n == 0) abort("Zero data points in interpolate");
  if(n == 1) return y[0];
  if(i < 0) {
    real dx=x[1]-x[0];
    return y[0]+(y[1]-y[0])/dx*(x0-x[0]);
  }
  if(i >= n-1) {
    real dx=x[n-1]-x[n-2];
    return y[n-1]+(y[n-1]-y[n-2])/dx*(x0-x[n-1]);
  }

  real D=x[i+1]-x[i];
  real B=(x0-x[i])/D;
  real A=1.0-B;
  return A*y[i]+B*y[i+1];
}

// Linearly interpolate data points (x,y) to (x0,y0), where the elements of
// real[] x are listed in ascending order and return y0. Values outside the
// available data range are linearly extrapolated using the first derivative
// at the nearest endpoint.
real interpolate(real[] x, real[] y, real x0) 
{
  return interpolate(x,y,x0,search(x,x0));
}

real node(path g, real x)
{
  real m=min(g).y;
  real M=max(g).y;
  return intersect(g,(x,m)--(x,M)).x;
}

real node(path g, explicit pair z)
{
  real m=min(g).x;
  real M=max(g).x;
  return intersect(g,(m,z.y)--(M,z.y)).x;
}

real value(path g, real x)
{
  return point(g,node(g,x)).y;
}

real value(path g, explicit pair z)
{
  return point(g,node(g,(0,z.y))).x;
}

real slope(path g, real x)
{
  pair a=dir(g,node(g,x));
  return a.y/a.x;
}

real slope(path g, explicit pair z)
{
  pair a=dir(g,node(g,(0,z.y)));
  return a.y/a.x;
}


