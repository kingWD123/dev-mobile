# Covoiturage

Application mobile Flutter qui met en relation des conducteurs ayant des places
libres et des passagers qui font le même trajet, entre les 14 régions
administratives du Sénégal.

Projet réalisé dans le cadre du cours de développement mobile (DIC2).

---

## Le problème

Chaque jour, des milliers de voitures relient Dakar aux régions avec deux ou
trois sièges vides, pendant que des voyageurs attendent une place dans un
transport en commun. L'offre et la demande existent des deux côtés, mais elles
n'ont aucun point de rendez-vous outillé. Aujourd'hui l'essentiel du covoiturage
sénégalais se négocie dans des groupes WhatsApp, sans recherche, sans
historique, et sans moyen de savoir à qui on a affaire.

L'application répond à trois manques précis :

| Manque | Réponse apportée |
| --- | --- |
| La rencontre, faute de place de marché commune | Recherche par région, date et nombre de passagers, trajets publiés visibles en temps réel |
| La confiance, parce qu'on ne sait pas qui conduit | Profil conducteur, véhicule, badge d'identité vérifiée, messagerie intégrée, suivi de trajet partageable |
| Le gaspillage des sièges vides sur des routes saturées | Un siège vide devient une place réservable, le coût du trajet est partagé |

---

## Fonctionnalités

L'application s'organise autour de cinq onglets.

### Rechercher

Choix de la région de départ et d'arrivée dans une liste fermée (les 14 régions
administratives), de la date et du nombre de passagers. La liste fermée remplace
la saisie libre pour deux raisons : les coordonnées sont toujours connues, donc
aucun géocodeur externe n'est nécessaire, et un trajet publié vers « Thiès » est
toujours retrouvé par une recherche vers « Thiès ». La page d'accueil affiche en
plus les derniers trajets publiés, mis à jour en direct.

### Résultats et détail du trajet

Chaque trajet affiche l'heure de départ, la durée estimée, le prix en FCFA, les
places restantes et le conducteur. Le détail présente en plus l'itinéraire tracé
sur une carte OpenStreetMap, le véhicule, les conditions incluses (bagages,
prise en charge, annulation) et le mode de réservation, instantané ou soumis à
confirmation du conducteur.

La réservation décrémente les places dans une transaction Firestore, ce qui
empêche deux passagers d'obtenir le même dernier siège. Elle déclenche aussi la
notification du conducteur et l'ouverture automatique d'une conversation entre
les deux parties, sans que personne ait à échanger son numéro.

### Publier un trajet

Itinéraire, date et heure, nombre de places, prix par passager et véhicule. La
durée est estimée automatiquement à partir de la distance orthodromique entre
les deux chefs-lieux, sur une base de 55 km/h de moyenne. Le conducteur choisit
s'il accepte la réservation instantanée ou s'il veut valider chaque demande.

### Mes trajets

Un seul écran pour les deux rôles, puisqu'on est rarement uniquement conducteur
ou uniquement passager. Les trajets publiés et les trajets réservés sont
fusionnés puis répartis entre « À venir » et « Passés ». Depuis un trajet à
venir, un bouton ouvre le suivi en direct : progression sur la carte, statuts
« en attente du départ », « en route » et « arrivé », appel du conducteur en un
geste, et partage du trajet à un proche.

### Messages et notifications

Messagerie temps réel par conversation, créée automatiquement à la réservation.
Le fil de notifications remonte chaque réservation, chaque message et chaque
événement du trajet.

### Profil

Nom, téléphone, véhicule, demande de vérification d'identité, préférences de
trajet (non-fumeur, animaux acceptés, musique) et compteurs de trajets effectués
comme conducteur et comme passager.

---

## Stack technique

| Brique | Choix |
| --- | --- |
| Framework | Flutter / Dart (`sdk: ^3.12.2`) |
| Interface | Material 3, thèmes clair et sombre suivant le réglage système |
| Backend | Firebase, avec Cloud Firestore en temps réel et Firebase Authentication |
| Cartographie | `flutter_map` sur les tuiles OpenStreetMap, `latlong2` pour la géométrie |
| Divers | `url_launcher` pour l'appel téléphonique, `share_plus` pour le partage de trajet |

Aucune API payante n'est utilisée. La cartographie repose sur OpenStreetMap et
le référentiel des régions est embarqué dans l'application.

---

## Architecture du code

```
lib/
├── main.dart                  point d'entrée : init Firebase, connexion, thème
├── firebase_options.dart      configuration générée par FlutterFire
├── data/
│   └── senegal_regions.dart   les 14 régions et les coordonnées de leur chef-lieu
├── theme/
│   └── app_theme.dart         palette et thèmes clair / sombre
├── services/                  couche d'accès aux données (aucune UI ici)
│   ├── auth_service.dart          connexion anonyme, exposition de l'uid
│   ├── firestore_safe.dart        accès Firestore tolérant à une init manquante
│   ├── ride_repository.dart       publication, flux de trajets, prise de place
│   ├── booking_repository.dart    réservation et trajets réservés
│   ├── chat_repository.dart       conversations et messages
│   ├── notification_repository.dart
│   └── user_repository.dart       profil et compteurs
├── screens/                   les 11 écrans
│   ├── home_shell.dart            navigation à 5 onglets
│   ├── search_screen.dart       · results_screen.dart    · ride_detail_screen.dart
│   ├── publish_ride_screen.dart · my_trips_screen.dart   · live_tracking_screen.dart
│   ├── messages_screen.dart     · chat_screen.dart       · notifications_screen.dart
│   └── profile_screen.dart
└── widgets/                   composants réutilisables
    ├── route_map.dart             carte OpenStreetMap et tracé de l'itinéraire
    ├── region_picker_sheet.dart   sélecteur de région
    ├── driver_avatar.dart · car_illustration.dart · promo_banner.dart
```

Les écrans ne parlent jamais directement à Firestore. Ils consomment les
`Stream` exposés par les repositories de `lib/services/`, ce qui garde la
logique de données concentrée en un seul endroit.

---

## Modèle de données Firestore

### `rides`, les trajets publiés

| Champ | Type | Remarque |
| --- | --- | --- |
| `from` / `to` | `string` | nom de la région |
| `fromLat` / `fromLng` / `toLat` / `toLng` | `number` | coordonnées du chef-lieu |
| `departure` | `timestamp` | date et heure de départ |
| `durationMinutes` | `int` | durée estimée |
| `seats` / `seatsTotal` | `int` | places restantes / places d'origine |
| `price` | `number` | prix par passager, en FCFA |
| `instantBooking` | `bool` | réservation sans validation du conducteur |
| `driverUid` / `driverName` / `driverCar` | `string` | conducteur |
| `createdAt` | `timestamp` | sert au tri des listes |

### `users/{uid}`, le profil

`name`, `phone`, `car`, `smokeFree`, `petsAllowed`, `music`, `readReceipts`,
`verified`, `verificationRequested`.

### `bookings`, les réservations

`uid` (passager), `rideId`, `from`, `to`, `departure`, `price`, `driverUid`,
`driverName`, `createdAt`.

### `notifications`

`forUid` (destinataire), `title`, `body`, `createdAt`.

### `conversations/{uidA_uidB}` et sa sous-collection `messages`

L'identifiant de conversation est déterministe : les deux uid triés par ordre
alphabétique et joints par `_`, ce qui garantit qu'une seule conversation existe
par paire d'utilisateurs.

- conversation : `participantUids` (array), `participantNames` (map uid → nom),
  `lastMessage`, `lastMessageAt`
- message : `text`, `senderUid`, `sentAt`

---

## Démarrage

### Prérequis

- Flutter (canal stable) et le SDK Android installés, avec un `flutter doctor` vert
- Node.js 18 ou plus, uniquement pour le script de données de démonstration

### Lancer l'application

```bash
flutter pub get
```

```bash
flutter run
```

### Construire l'APK

```bash
flutter build apk --release
```

L'APK est produit dans `build/app/outputs/flutter-apk/app-release.apk`.

> La configuration de build signe actuellement la version release avec la clé de
> debug (voir `android/app/build.gradle.kts`). C'est suffisant pour installer
> l'application à la main, pas pour une publication sur le Play Store.

### Configuration Firebase

Le projet est branché sur le projet Firebase `covoiturage-dic2`. Pour le
rebrancher ailleurs :

```bash
flutterfire configure
```

Cette commande régénère `lib/firebase_options.dart` et
`android/app/google-services.json`.

Côté console Firebase, deux réglages sont nécessaires.

**1. Authentication, puis Sign-in method, puis Anonymous, puis Enable.**
L'application ouvre une session anonyme au démarrage et s'en sert comme identité
de l'utilisateur. Sans ce fournisseur activé, `AuthService.uid` reste `null` et
les écrans Mes trajets, Messages, Notifications et Profil restent vides.

**2. Firestore, les index composites.** Quatre requêtes combinent un filtre et un
tri sur un autre champ, et réclament donc un index :

| Collection | Filtre | Tri |
| --- | --- | --- |
| `rides` | `driverUid ==` | `createdAt` desc |
| `bookings` | `uid ==` | `createdAt` desc |
| `notifications` | `forUid ==` | `createdAt` desc |
| `conversations` | `participantUids array-contains` | `lastMessageAt` desc |

Au premier lancement, Firestore renvoie dans la console un lien direct de
création pour chacun, qu'il suffit de suivre.

---

## Données de démonstration

`tool/seed_demo_data.js` remplit Firestore avec un jeu de données présentable :
6 conducteurs et 15 trajets répartis sur le pays, aux prix réalistes, datés
relativement à aujourd'hui pour rester toujours à venir.

```bash
node tool/seed_demo_data.js
```

Le script passe par l'API REST de Firestore et n'a besoin d'aucun compte de
service. Il se connecte anonymement, comme le fait l'application.

| Commande | Effet |
| --- | --- |
| `node tool/seed_demo_data.js` | crée les conducteurs et les trajets |
| `node tool/seed_demo_data.js --list-users` | liste les uid connus, pour retrouver le sien |
| `node tool/seed_demo_data.js --for-uid <uid>` | ajoute réservations, notifications et une conversation pour cet utilisateur |
| `node tool/seed_demo_data.js --reset` | supprime uniquement les documents créés par le script |

Tous les documents créés portent un champ `demoSeed: true`, ce qui permet au
mode `--reset` de ne jamais toucher aux données réelles.

---

## Sécurité

`firestore.rules` n'autorise les lectures et écritures qu'aux utilisateurs
authentifiés :

```
match /{document=**} {
  allow read, write: if request.auth != null;
}
```

Il n'y a qu'une barrière d'authentification, sans contrôle de propriété document
par document, parce que l'application écrit légitimement sur les documents
d'autres utilisateurs quand elle notifie un conducteur ou ouvre une
conversation.

Ces règles doivent être déployées pour être actives. Tant qu'elles ne le sont
pas, la base reste dans le mode test ouvert créé par défaut :

```bash
firebase deploy --only firestore:rules
```

---

## Limites connues et suite

- Le suivi en direct est simulé. La progression est interpolée entre l'heure de
  départ et la durée estimée, il n'y a pas encore de remontée de position GPS
  réelle.
- L'itinéraire est une ligne directe entre les deux chefs-lieux, pas un tracé
  routier calculé.
- La vérification d'identité enregistre la demande mais n'inclut pas encore de
  contrôle de pièce justificative.
- Il n'y a pas encore de paiement. Le prix est affiché et convenu entre les
  utilisateurs. L'intégration de Wave et Orange Money est la première étape de
  la suite, devant la notation mutuelle après trajet et les trajets récurrents
  pour les navetteurs.

---

## Tests et qualité

```bash
flutter analyze
```

```bash
flutter test
```
