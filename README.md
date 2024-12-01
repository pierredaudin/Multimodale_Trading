# Application de Trading Multimodale

## **Aperçu**
L'application de trading multimodale est une interface interactive qui combine des commandes vocales et des gestes pour une expérience utilisateur intuitive. Elle intègre un graphique de trading dynamique et permet de tracer des formes comme des lignes ou des rectangles sur ce graphique. Pour plus de détails sur la partie technique, voir le [Rapport Technique](Rapport/RAPPORT.md).

## **Installation**

### **Prérequis**
- **Processing IDE** : Téléchargez et installez depuis [processing.org](https://processing.org/).
- **SRA5 (Reconnaissance vocale)** : Dans les fichiers du projet.
- **Java JDK** : Assurez-vous que Java est installé et configuré sur votre système.
- **Bibliothèque Ivy** : Incluse dans les fichiers du projet.

### **Fichiers du projet**
- `OneDollarIvy.pde` : Point d'entrée principal de l'application.
- `Recognizer.pde` : Reconnaissance de formes basée sur les gestes.
- `Recorder.pde` : Gestion de l'enregistrement des gestes pour la reconnaissance.
- `Result.pde` : Gestion des résultats de la reconnaissance.
- `Template.pde` : Gestion des modèles pour la reconnaissance des formes.
- `FSM.pde` : Machine à états pour gérer les interactions utilisateur.
- `Point.pde` : Classe représentant un point dans l'espace.
- `grammar.grxml` : Grammaire pour la reconnaissance vocale.
- `Trading_Multimodale.bat` : Script batch pour lancer l'application.

### **Configuration**
Clonez ou téléchargez ce projet en utilisant la commande suivante :
```sh
git clone https://github.com/pierredaudin/Multimodale_Trading
```

---

## **Lancement**

### **Étape 1 : Démarrer l'application**
Exécutez le fichier batch pour lancer les différentes composantes de l'application :
1. Double-cliquez sur `Trading_Multimodale.bat` pour démarrer l'application Processing et le service SRA5.
2. Le script batch démarrera l'application principale ainsi que SRA5 avec la grammaire appropriée.

### **Contenu du fichier batch**
Le fichier batch (`Trading_Multimodale.bat`) contient les commandes suivantes :
```batch
cd Interface_Trading
start trading_multimodale.exe
cd ..

cd sra5
sra5.exe -b 127.255.255.255:2010 -g grammar.grxml -p on
pause
```
Ce script permet de démarrer automatiquement l'application de trading ainsi que le module de reconnaissance vocale SRA5.

### **Étape 2 : Utiliser l'application**
Une fois les deux services en marche, vous pouvez :
- Donner des **commandes vocales** (e.g., "Créer une forme en rouge").
- Tracer des formes en utilisant des gestes (reconnaissance basée sur le $1 Recognizer).


### **Vidéos de démonstration**
Pour voir des exemples d'utilisation, téléchargez et consultez les vidéos suivantes dans le dossier `vidéo` :
- [ligne.mp4](vidéo/ligne.mp4) : Démonstration de la création d'une ligne.
- [rectangle.mp4](vidéo/rectangle.mp4) : Démonstration de la création d'un rectangle.
- [multiforme.mp4](vidéo/multiforme.mp4) : Démonstration de la création de plusieurs formes.

---

## **Explication Technique**

### **Architecture du Projet**

#### **Classes principales**
1. **OneDollarIvy** : Gère l'interface graphique, l'état de l'application, et l'intégration des fonctionnalités principales.
2. **DynamicShape** : Représente des formes tracées sur le graphique, telles que les lignes ou les rectangles.
3. **FSM** : Implémente la machine à états pour gérer le flux d'interactions utilisateur.
4. **Recognizer** : Basé sur le $1 Recognizer, permet de détecter des formes tracées.
5. **Recorder** : Enregistre les points d'un geste pour la reconnaissance.
6. **Template** : Contient les modèles pour la reconnaissance des formes.
7. **SRA5 Integration** : Gère les interactions avec le moteur de reconnaissance vocale.

---

### **Fonctionnalités**

1. **Graphique de trading dynamique**
   - Affichage en temps réel des bougies japonaises.
   - Possibilité de geler le graphique pour tracer des formes précises.

2. **Tracer des formes**
   - Types de formes : Lignes, rectangles.

3. **Reconnaissance vocale**
   - Basée sur le moteur **SRA5** et une grammaire personnalisée (`grammar.grxml`).
   - Commandes disponibles :
     - Tracer une forme : "Créer une forme en vert".
     - Capturer des points : "De ici à là".

4. **Gestion des formes dynamiques**
   - Les formes restent synchronisées avec le graphique.
   - Les formes suivent le défilement du graphique.

---

### **États de l'application (FSM)**

1. **INIT**
   - Attente d'une commande initiale pour commencer l'interaction.

2. **SHAPE_DETECTION**
   - Reconnaissance des gestes pour identifier la forme.

3. **WAIT_FIRST_POINT**
   - Attente de la commande vocale pour capturer le premier point.

4. **WAIT_SECOND_POINT**
   - Attente de la commande vocale pour capturer le deuxième point.

5. **DRAW_SHAPE**
   - Ajout de la forme reconnue et liaison avec le graphique.

---

### **Dépendances et Intégrations**
- **Processing** : Gestion de l'interface graphique et du flux principal.
- **Ivy Framework** : Communication entre les modules (e.g., SRA5).
- **SRA5** : Reconnaissance vocale avec grammaire personnalisée.
- **$1 Recognizer** : Reconnaissance des gestes.

---

## **Licence**
Ce projet est distribué sous la licence [MIT](https://opensource.org/licenses/MIT).
