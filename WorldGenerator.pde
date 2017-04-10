class Particle {
  PVector pos = new PVector();
  PVector vel = new PVector();
  PVector acc = new PVector();
  float r;
  float offset = radians(0);
  float mass;
  
  Particle(float r_, float x, float y) {
    pos.set(x, y);
    vel.set(0, 0);
    acc.set(0, 0);
    r = r_;
    mass = r / 8;
  }

  void addForce(PVector force) {
    acc.add(PVector.div(force, mass));
  }

  void update() {
    vel.add(acc);
    pos.add(vel);
    acc.mult(0);
  }

  void display() {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(vel.heading()+offset);
    stroke(0);
    strokeWeight(2);
    fill(127);
    ellipse(0, 0, r*2, r*2);
    line(0, 0, r, 0);
    popMatrix();
  }
}

class World {
  PVector gravity = new PVector();

  World(float yGravity) {
    gravity.set(0, yGravity);
  }

  void setXGravity(float xGravity) {
    gravity.set(xGravity, gravity.y);
  }

  void addParticle(Particle p) {
    p.addForce(gravity);
  }
}

class Target {
  PVector pos = new PVector();
  float r;
  color col = color(175, 50);

  Target(float r_, float x, float y) {
    pos.set(x, y);
    r = r_;
  }

  boolean hovered() {
    PVector mouse = new PVector(mouseX, mouseY);
    float d = PVector.dist(mouse, pos);
    return (d < r);
  }

  boolean clicked() {
    PVector mouse = new PVector(mouseX, mouseY);
    float d = PVector.dist(mouse, pos);
    return (d < r && mousePressed);
  }
  
  PVector attractionForce(Particle p) {
    float G = 6.67408;
    PVector particlePos = p.pos;
    PVector force = PVector.sub(pos, particlePos);
    float distance = force.mag();
    distance = constrain(distance, 1, 5);
    force.normalize();
    float strength = (G * 1 * p.mass) / (distance * distance);
    force.mult(strength);
    return force;
  }
  
  void update() {
    PVector vel = new PVector(random(-1, 1), random(-1, 1));
    pos.add(vel);
  }

  void display() {
    stroke(0);
    strokeWeight(2);
    fill(col);
    ellipse(pos.x, pos.y, r*2, r*2);
  }
}

World world;
ArrayList<Particle> particles;
ArrayList<Target> targets;

void setup() {
  size(600, 400);
  world = new World(0);
  world.setXGravity(0);
  particles = new ArrayList<Particle>();
  targets = new ArrayList<Target>();
  targets.add(new Target(32, width/2, height/2));
  particles.add(new Particle(random(8, 16)*1.5, random(width), random(height)));
}

void draw() {
  background(255);
  fill(0);
  text("click on one of the targets to add new target at random location", 10, 25);
  text("'t' to add a new target at mouse location", 10, 50);
  text("'p' to add a new particle at mouse location", 10, 75);
  for (Particle p : particles) {
    world.addParticle(p);
    for (Target t : targets) {
      p.addForce(t.attractionForce(p));
    }
    p.update();
    p.display();
    p.offset += radians(5);
  }
  for (int i = targets.size()-1; i >= 0; i--) {
    Target t = targets.get(i);
    if (t.hovered()) {
      t.col = color(100);
    }
    if (t.clicked()) {
      t.col = color(50);
    }
    if (!t.hovered()) {
      t.col = color(175, 50);
    }
    t.update();
    t.display();
  }
}

void keyPressed() {
  if (key == 't') {
    targets.add(new Target(32, mouseX, mouseY));
    println("adding new target");
  } else if (key == 'p') {
    particles.add(new Particle(random(8, 16)*1.5, mouseX, mouseY));
    println("adding new particle");
  }
}

void mousePressed() {
  for (int i = targets.size()-1; i >= 0; i--) {
    Target t = targets.get(i);
    if (t.hovered()) {
      targets.add(new Target(32, random(width), random(height)));
    }
  }
}
