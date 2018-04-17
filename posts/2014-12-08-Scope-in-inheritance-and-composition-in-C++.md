---
layout: post
title: Scope in inheritance and composition in C++.
date: 2014-12-08 18:00:33
tags: Programming, OOP, C++
---

I hope you read my previous post before looking at this one if you don't know much about OOP in C++. The previous post explains various things like naming of stuff in C++ which is different from naming conventions in other languages.

This one is about explaining scope in C++ when we have inheritance and non-default constructors as well as compositions.

The piont of this post is to establish:

1. What order are constructors called in case we create an object of a derived class.
2. What order are destructors called in case we destroy an object of a derived class.
3. In the case of compositions (objects as data members) which constructors are called first. The one of the composing class or the object?


Anyway let's get to it.

```c++
#include <iostream>

using namespace std;

class parent {
public:
  parent() {
    cout << "Parent object created." << endl;
  }
  ~parent() {
    cout << "Parent object destoyed." << endl;
  }
};

class child: public parent {
public:
  child() {
    cout << "Child object created." << endl;
  }
  ~child() {
    cout << "Child object destoyed." << endl;
  }
};

class composition {
child* childObj;
public:
  composition() {
    cout << "Composing object created" << endl;
    childObj = new child;
  }

  ~composition() {
    delete childObj;
    cout << "Composed oject destroyed." << endl;
  }
};

int main () {
  composition compObject;
  return 0;
}
```

Output:

```
Composing object created
Parent object created.
Child object created.
Child object destoyed.
Parent object destoyed.
Composed oject destroyed.
```

So what do we see here:

1. The composed object is created before the objects in it.
2. The parent class is created before the child class.
3. They are then destroyed in reverse order of their creation. Child then parent then composing.

It's really that simple.

Hail Stallman and may the FOSS be with you.
