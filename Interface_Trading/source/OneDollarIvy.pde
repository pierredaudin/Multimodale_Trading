import fr.dgac.ivy.*;
import javax.swing.JOptionPane;
import java.util.ArrayList;

// Déclaration des variables principales
Ivy bus;
Recognizer recognizer;
Recorder recorder;
Result result;

// Machine à états
FSMState currentState;
String s_result = "";
String recognizedShape = ""; // Forme reconnue par le $1 Recognizer
int currentColor = color(0, 0, 0); // Couleur par défaut : noir
String lastVoiceCommand = "";

// Liste pour mémoriser les formes dessinées
ArrayList<DynamicShape > dynamicShapes = new ArrayList<>();

// Variables pour le $1 Recognizer
int NumTemplates = 16;
int NumPoints = 64;
float SquareSize = 250.0;
float HalfDiagonal = 0.5 * sqrt(250.0 * 250.0 + 250.0 * 250.0);
float AngleRange = 45.0;
float AnglePrecision = 2.0;
float Phi = 0.5 * (-1.0 + sqrt(5.0)); // Golden Ratio

// Données pour le graphique de trading
float[] openPrices, closePrices, highPrices, lowPrices;
float candleWidth = 10;
int numCandles = 80; // Nombre de bougies affichées
int frameCounter = 0; // Pour ralentir le défilement du graphique
float priceCenter = 300; // Point de référence pour générer les prix
boolean freezeGraph = false; // Indique si le graphique doit être bloqué


// Coordonnées des points
float startX = -1, startY = -1, endX = -1, endY = -1;

// États possibles
enum FSMState {
  INIT,
  SHAPE_DETECTION,
  WAIT_POINTS,
  DRAW_SHAPE,
  WAIT_FIRST_POINT,
  WAIT_SECOND_POINT
}

// Classe pour représenter une forme
class DynamicShape {
  String type;
  float x1, y1, x2, y2; // Coordonnées relatives au graphique
  color shapeColor;

  DynamicShape(String type, float x1, float y1, float x2, float y2, color shapeColor) {
    this.type = type;
    this.x1 = x1;
    this.y1 = y1;
    this.x2 = x2;
    this.y2 = y2;
    this.shapeColor = shapeColor;
  }

  void updatePosition(float offsetX) {
    x1 -= offsetX;
    x2 -= offsetX;
  }

  void display() {
    stroke(shapeColor);
    if (type.equals("ligne")) {
      line(x1, y1, x2, y2);
    } else if (type.equals("rectangle")) {
      // Tracer les quatre lignes du rectangle
      line(x1, y1, x2, y1); // Ligne supérieure
      line(x1, y2, x2, y2); // Ligne inférieure
      line(x1, y1, x1, y2); // Ligne gauche
      line(x2, y1, x2, y2); // Ligne droite
    }
  }
}


void setup() {
  size(800, 600);
  currentState = FSMState.INIT;
  
  // Initialisation des données du graphique
  initializePrices();

  // Initialisation du $1 Recognizer
  recognizer = new Recognizer();
  recorder = new Recorder();
  
  recognizer.Import();

  // Initialisation du bus Ivy
  try {
    bus = new Ivy("OneDollarIvy", "OneDollarIvy is ready", null);
    bus.start("127.255.255.255:2010");

    // Gestion des commandes vocales
    bus.bindMsg("^sra5 Text=(.*) Confidence=.*", new IvyMessageListener() {
      public void receive(IvyClient client, String[] args) {
        lastVoiceCommand = args[0].toLowerCase();
        println("Commande vocale reçue : " + lastVoiceCommand); // Log pour débogage
        handleVoiceCommand(lastVoiceCommand);
      }
    });
  } catch (IvyException ie) {
    println("Erreur de connexion au bus Ivy : " + ie);
  }
}

void draw() {
  background(40);
  textSize(18);
  fill(0);
  textAlign(CENTER);
  
  // Dessin du graphique (en arrière-plan)
  if (freezeGraph) {
    drawStaticTradingChart();
  } else {
    drawTradingChart();
  }

  // Afficher les formes mémorisées
  for (DynamicShape  shape : dynamicShapes) {
    shape.display();
  }

  // Afficher l'état et la commande vocale
  fill(255);
  text("État actuel : " + currentState, width / 2, 30);
  text("Dernière commande vocale : " + lastVoiceCommand, width / 2, 550);

  switch (currentState) {
    case INIT:
      fill(255);
      text("Dites 'créer une forme' ou 'dessine une forme' pour commencer.", width / 2, height / 2);
      break;

    case SHAPE_DETECTION:
      fill(255);
      text("Tracez une forme pour la reconnaissance.", width / 2, height / 2);
      recorder.update();
      recorder.draw();

      if (recorder.hasPoints) {
        Point[] points = recorder.points;
        result = recognizer.Recognize(points);
        recorder.hasPoints = false;
      }

      if (result != null) {
        recognizedShape = result.Name; // Forme reconnue
        if (!recognizedShape.isEmpty() && !recognizedShape.equals("NONE")) {
          println("Forme reconnue : " + recognizedShape);
          currentState = FSMState.WAIT_FIRST_POINT;
        } else {
          println("Forme non reconnue, veuillez réessayer.");
        }
        result = null; // Réinitialiser
      }
      break;

    case WAIT_FIRST_POINT:
      freezeGraph = true; // Bloquer le graphique
      fill(255);
      text("Dites 'd'ici' pour définir le premier point.", width / 2, height / 2);
      break;

    case WAIT_SECOND_POINT:
    fill(255);
      text("Dites 'à là' pour définir le deuxième point.", width / 2, height / 2);
      break;

    case DRAW_SHAPE:
      if (isValidPoints(startX, startY, endX, endY)) {
        // Ajouter la forme dynamique liée au graphique
        dynamicShapes.add(new DynamicShape(recognizedShape, startX, startY, endX, endY, currentColor));
        println("Forme ajoutée et attachée au graphique : " + recognizedShape);
      } else {
        println("Points invalides, opération annulée.");
      }
      freezeGraph = false; // Débloquer le graphique
      resetState();
      break;
  }
}

void handleVoiceCommand(String command) {
  if (command.contains("rouge")) currentColor = color(255, 0, 0);
  else if (command.contains("vert")) currentColor = color(0, 255, 0);
  else if (command.contains("bleu")) currentColor = color(0, 0, 255);
  else if (command.contains("jaune")) currentColor = color(255, 255, 0);
  else if (command.contains("noir")) currentColor = color(0, 0, 0);
  else if (command.contains("blanc")) currentColor = color(255, 255, 255);

  if (command.contains("créer") || command.contains("dessine")) {
    println("Commande reconnue : Créer une forme.");
    currentState = FSMState.SHAPE_DETECTION;
  } else if ((command.contains("d'ici") || command.contains("de ici")) && currentState == FSMState.WAIT_FIRST_POINT) {
    startX = mouseX;
    startY = mouseY;
    println("Premier point défini à (" + startX + ", " + startY + ")");
    currentState = FSMState.WAIT_SECOND_POINT;
  } else if (command.contains("à là") && currentState == FSMState.WAIT_SECOND_POINT) {
    endX = mouseX;
    endY = mouseY;
    println("Deuxième point défini à (" + endX + ", " + endY + ")");
    currentState = FSMState.DRAW_SHAPE;
  }
}

boolean isValidPoints(float x1, float y1, float x2, float y2) {
  return x1 >= 0 && y1 >= 0 && x2 >= 0 && y2 >= 0;
}

void resetState() {
  startX = -1;
  startY = -1;
  endX = -1;
  endY = -1;
  recognizedShape = "";
  currentState = FSMState.INIT;
}

// Initialisation des données pour le graphique
void initializePrices() {
  openPrices = new float[numCandles];
  closePrices = new float[numCandles];
  highPrices = new float[numCandles];
  lowPrices = new float[numCandles];

  float price = priceCenter;
  for (int i = 0; i < numCandles; i++) {
    float open = price + random(-20, 20);
    float close = open + random(-20, 20);
    float high = max(open, close) + random(5, 10);
    float low = min(open, close) - random(5, 10);

    openPrices[i] = open;
    closePrices[i] = close;
    highPrices[i] = high;
    lowPrices[i] = low;
    price = close;
  }
}

// Dessiner le graphique
void drawTradingChart() {
  frameCounter++;
  if (frameCounter % 60 == 0) {
    shiftPrices();
    frameCounter = 0;
  }

  for (int i = 0; i < numCandles; i++) {
    float x = i * candleWidth;
    float open = openPrices[i];
    float close = closePrices[i];
    float high = highPrices[i];
    float low = lowPrices[i];

    stroke(150);
    line(x + candleWidth / 2, height - high, x + candleWidth / 2, height - low);

    if (close > open) fill(0, 255, 0);
    else fill(255, 0, 0);

    noStroke();
    rect(x, height - max(open, close), candleWidth - 2, abs(open - close));
  }
}

// Déplacer les prix pour simuler un défilement
void shiftPrices() {
  for (int i = 0; i < numCandles - 1; i++) {
    openPrices[i] = openPrices[i + 1];
    closePrices[i] = closePrices[i + 1];
    highPrices[i] = highPrices[i + 1];
    lowPrices[i] = lowPrices[i + 1];
  }

  float open = closePrices[numCandles - 2] + random(-20, 20);
  float close = open + random(-20, 20);
  float high = max(open, close) + random(5, 10);
  float low = min(open, close) - random(5, 10);

  openPrices[numCandles - 1] = open;
  closePrices[numCandles - 1] = close;
  highPrices[numCandles - 1] = high;
  lowPrices[numCandles - 1] = low;

  for (DynamicShape shape : dynamicShapes) {
    shape.updatePosition(candleWidth);
  }
}

// Dessiner le graphique sans le faire défiler
void drawStaticTradingChart() {
  for (int i = 0; i < numCandles; i++) {
    float x = i * candleWidth;
    float open = openPrices[i];
    float close = closePrices[i];
    float high = highPrices[i];
    float low = lowPrices[i];

    stroke(150);
    line(x + candleWidth / 2, height - high, x + candleWidth / 2, height - low);

    if (close > open) fill(0, 255, 0);
    else fill(255, 0, 0);

    noStroke();
    rect(x, height - max(open, close), candleWidth - 2, abs(open - close));
  }
}
