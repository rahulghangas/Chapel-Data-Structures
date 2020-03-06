module SearchTree {

  /*
    Binary Search tree in Chapel
    Algorithm :- AVL trees
  */

  class _binaryNode {
    type eltType;
    var value: eltType;
    var height : int;
    
    // Depth is not really needed, should we keep it?
    var depth : int;
    
    var parent : unmanaged _binaryNode(eltType)?;
    var left: unmanaged _binaryNode(eltType)?;
    var right: unmanaged _binaryNode(eltType)?;

    proc init(type eltType, parent : unmanaged _binaryNode(eltType)?, value){
      this.eltType = eltType;
      this.value = value;
      height = 1;
      this.parent = parent;
      if parent == nil { 
        depth = 1; 
      }else{
        depth = parent!.depth;
      }
    }
  }

  record AVLTree {
    type eltType;
    var _root : unmanaged _binaryNode(eltType)?;

    proc init(type eltType) {
      this.eltType = eltType;
    }

    proc contains(x : eltType) {
      var current = _root;
      while current != nil {
        if x == current.value {
          return true;
        }
      }
      return false;
    }

    proc insert(x : eltType) {
      if _root == nil {
        _root = new unmanaged _binaryNode(eltType, nil, x);
      }else{
        //insert element by traversing down the tree
        var current = _root;
        while true {
          current!.height += 1;
          if x < current!.value {
            if current!.left == nil {
              current!.left = new unmanaged _binaryNode(eltType, current, x);
              break;
            }else {
              current = current!.left;
            }
          }else if x > current!.value{
            if current!.right == nil {
              current!.right = new unmanaged _binaryNode(eltType, current, x);
              break;
            }else {
              current = current!.right;
            }
          }else{
            // retractDepthUpdate(current);
            halt("Can't have multiple keys of same value");
          }
        }

        // Balance iteratively while traversing the tree upwards
        while(true){
          var balance = getBalance(current);

          
          if balance > 1 && x < current!.left!.value {              // LL Rotation
            current = rightRotate(current);
          }else if balance < -1 && x > current!.right!.value{       // RR Rotation
            current = leftRotate(current);
          }else if balance > 1 && x > current!.left!.value{         // LR Rotation
            current!.left = leftRotate(current!.left);
            current = rightRotate(current);
          }else if balance < -1 && x < current!.right!.value{       // RL Rotation
            current!.right = rightRotate(current!.right);
            current = leftRotate(current);
          }

          if current!.parent == nil{
            _root = current;
            return;
          }else{
            current = current!.parent;
          }
        }
      }
    }

    // Since we have pointer to parent now, can probably do without keeping a stack
    iter inorder() {
      if _root == nil then return;

      private use List;
      var stack = new list(unmanaged _binaryNode(eltType));

      var current = _root;
      while true {
        if current != nil {
          stack.append(current!);
          current = current!.left;
        } else if !stack.isEmpty() {
          current = stack.pop();
          yield current!.value;
          current = current!.right;
        } else {
          break;
        }
      }
    }
    
  }

  inline proc getHeight(node){
      if node == nil then return 0; else return node!.height;
    }

  proc getBalance(node){
    return getHeight(node!.left) - getHeight(node!.right); 
  }

  proc leftRotate(z){
    var y = z!.right;
    var T2 = y!.left;

    y!.left = z;
    // Update pointer to parent and pointer from parent
    y!.parent = z!.parent;
    if z!.parent != nil{
      if z == z!.parent!.right then z!.parent!.right = y; else z!.parent!.left = y;
    }
    z!.parent = y;

    z!.right = T2;
    if T2 != nil then T2!.parent = z;

    // Update height accordingly
    z!.height = 1 + max(getHeight(z!.left), getHeight(z!.right));
    y!.height = 1 + max(getHeight(y!.left), getHeight(y!.right));

    return y; 
  }

  proc rightRotate(z){
    var y = z!.left;
    var T3 = y!.right;

    y!.right = z;
    // Update pointer to parent and pointer from parent
    y!.parent = z!.parent;
    if z!.parent != nil{
      if z == z!.parent!.right then z!.parent!.right = y; else z!.parent!.left = y;
    }
    z!.parent = y;

    z!.left = T3;
    if T3 != nil then T3!.parent = z;

    // Update height accordingly
    z!.height = 1 + max(getHeight(z!.left), getHeight(z!.right));
    y!.height = 1 + max(getHeight(y!.left), getHeight(y!.right));

    return y;
  }

}
use SearchTree;
var a = new AVLTree(int);
a.insert(10);
writeln(a.inorder());
a.insert(20);
writeln(a.inorder());
a.insert(30);
writeln(a.inorder());
a.insert(40);
writeln(a.inorder());
a.insert(50);
writeln(a.inorder());
a.insert(25);
writeln(a.inorder());