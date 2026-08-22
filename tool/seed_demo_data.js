/**
 * Remplit Firestore avec un jeu de donnees de demonstration (conducteurs,
 * trajets, et optionnellement reservations / notifications / conversation).
 *
 * Passe par l'API REST : connexion anonyme via Identity Toolkit (comme
 * AuthService dans l'app), puis ecriture sur firestore.googleapis.com. Aucun
 * compte de service n'est necessaire, la cle web de firebase_options suffit.
 *
 *   node tool/seed_demo_data.js                  # conducteurs + trajets
 *   node tool/seed_demo_data.js --list-users     # liste les uid connus
 *   node tool/seed_demo_data.js --for-uid <uid>  # + reservations/notifs/chat
 *   node tool/seed_demo_data.js --reset          # efface les docs de demo
 */

const PROJECT_ID = 'covoiturage-dic2';
const API_KEY = 'AIzaSyBRveQRlCk9rCgSVK1gbuwChLdgFxx76dU';
const BASE = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents`;

// --- typage des valeurs Firestore REST -------------------------------------

const S = (v) => ({ stringValue: v });
const I = (v) => ({ integerValue: String(v) });
const D = (v) => ({ doubleValue: v });
const B = (v) => ({ booleanValue: v });
const T = (d) => ({ timestampValue: d.toISOString().replace(/\.\d{3}Z$/, 'Z') });
const A = (vals) => ({ arrayValue: { values: vals } });
const M = (fields) => ({ mapValue: { fields } });

// --- appels HTTP ------------------------------------------------------------

let idToken = null;

/**
 * Tente la connexion anonyme. Si le fournisseur Anonymous n'est pas active
 * dans la console Firebase (CONFIGURATION_NOT_FOUND), on retombe sur un acces
 * par cle API : cela ne marche que tant que les regles Firestore sont ouvertes,
 * ce qui est le cas du mode test.
 */
async function signInAnonymously() {
  const res = await fetch(
    `https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${API_KEY}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ returnSecureToken: true }),
    },
  );
  const body = await res.json();
  if (!res.ok) {
    const reason = body.error ? body.error.message : res.status;
    console.log(`  connexion anonyme indisponible (${reason}) -> ecriture par cle API`);
    return null;
  }
  idToken = body.idToken;
  console.log(`  connecte (uid technique ${body.localId})`);
  return body.localId;
}

async function call(method, path, body) {
  const url = idToken ? `${BASE}${path}` : `${BASE}${path}${path.includes('?') ? '&' : '?'}key=${API_KEY}`;
  const res = await fetch(url, {
    method,
    headers: Object.assign(
      { 'Content-Type': 'application/json' },
      idToken ? { Authorization: `Bearer ${idToken}` } : {},
    ),
    body: body ? JSON.stringify(body) : undefined,
  });
  const text = await res.text();
  if (!res.ok) throw new Error(`${method} ${path} -> ${res.status} ${text}`);
  return text ? JSON.parse(text) : {};
}

const addDoc = (collection, fields) => call('POST', `/${collection}`, { fields });
const setDoc = (collection, id, fields) =>
  call('PATCH', `/${collection}/${encodeURIComponent(id)}`, { fields });
const deleteDoc = (path) => call('DELETE', `/${path}`);
const listDocs = (collection, pageSize = 300) =>
  call('GET', `/${collection}?pageSize=${pageSize}`);

// --- geometrie : meme estimation que RideRepository._estimateDuration -------

function durationMinutes(from, to) {
  const R = 6371;
  const rad = (x) => (x * Math.PI) / 180;
  const dLat = rad(to[0] - from[0]);
  const dLng = rad(to[1] - from[1]);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(rad(from[0])) * Math.cos(rad(to[0])) * Math.sin(dLng / 2) ** 2;
  const km = 2 * R * Math.asin(Math.sqrt(a));
  return Math.min(Math.max(Math.round((km / 55) * 60), 15), 24 * 60);
}

// --- referentiel ------------------------------------------------------------

const REGIONS = {
  'Dakar': [14.6928, -17.4467],
  'Thiès': [14.791, -16.9359],
  'Diourbel': [14.6529, -16.2312],
  'Fatick': [14.339, -16.4111],
  'Kaffrine': [14.1059, -15.5508],
  'Kaolack': [14.1652, -16.0726],
  'Kédougou': [12.5556, -12.1747],
  'Kolda': [12.8983, -14.9412],
  'Louga': [15.6173, -16.224],
  'Matam': [15.6559, -13.2548],
  'Saint-Louis': [16.0326, -16.4818],
  'Sédhiou': [12.7081, -15.5569],
  'Tambacounda': [13.7707, -13.6673],
  'Ziguinchor': [12.5833, -16.2719],
};

const DRIVERS = [
  { uid: 'demo_amadou',   name: 'Amadou Diallo', phone: '+221 77 812 44 09', car: 'Toyota Corolla grise', verified: true,  smokeFree: true,  petsAllowed: false, music: true },
  { uid: 'demo_fatou',    name: 'Fatou Ndiaye',  phone: '+221 78 445 21 76', car: 'Hyundai Tucson blanc', verified: true,  smokeFree: true,  petsAllowed: true,  music: true },
  { uid: 'demo_moussa',   name: 'Moussa Sarr',   phone: '+221 76 330 18 52', car: 'Peugeot 308 bleue',    verified: true,  smokeFree: false, petsAllowed: false, music: false },
  { uid: 'demo_aissatou', name: 'Aïssatou Bâ',   phone: '+221 77 209 63 40', car: 'Renault Duster beige', verified: true,  smokeFree: true,  petsAllowed: true,  music: false },
  { uid: 'demo_ibrahima', name: 'Ibrahima Faye', phone: '+221 70 651 09 33', car: 'Kia Picanto rouge',    verified: false, smokeFree: true,  petsAllowed: false, music: true },
  { uid: 'demo_ndeye',    name: 'Ndèye Sow',     phone: '+221 77 984 55 12', car: 'Toyota RAV4 noir',     verified: true,  smokeFree: true,  petsAllowed: false, music: true },
];

// jours/heures relatifs a maintenant pour que la demo reste toujours "a venir"
function at(dayOffset, hour, minute = 0) {
  const d = new Date();
  d.setDate(d.getDate() + dayOffset);
  d.setHours(hour, minute, 0, 0);
  return d;
}

// L'ordre compte : la recherche et l'accueil trient par createdAt decroissant,
// donc les derniers de cette liste sont ceux qui remontent en premier.
const RIDES = [
  { from: 'Dakar',       to: 'Tambacounda', driver: 'demo_moussa',   day: 4, h: 6,  m: 0,  price: 12000, seats: 4, taken: 2, instant: false },
  { from: 'Ziguinchor',  to: 'Kolda',       driver: 'demo_ibrahima', day: 3, h: 9,  m: 30, price: 4000,  seats: 3, taken: 0, instant: true  },
  { from: 'Dakar',       to: 'Matam',       driver: 'demo_aissatou', day: 5, h: 5,  m: 30, price: 13000, seats: 4, taken: 3, instant: false },
  { from: 'Dakar',       to: 'Louga',       driver: 'demo_ndeye',    day: 2, h: 15, m: 0,  price: 5500,  seats: 3, taken: 1, instant: true  },
  { from: 'Kaolack',     to: 'Dakar',       driver: 'demo_fatou',    day: 2, h: 7,  m: 0,  price: 5000,  seats: 4, taken: 2, instant: true  },
  { from: 'Dakar',       to: 'Diourbel',    driver: 'demo_ibrahima', day: 1, h: 17, m: 30, price: 3500,  seats: 2, taken: 0, instant: true  },
  { from: 'Saint-Louis', to: 'Dakar',       driver: 'demo_amadou',   day: 3, h: 16, m: 0,  price: 6500,  seats: 3, taken: 1, instant: false },
  { from: 'Dakar',       to: 'Ziguinchor',  driver: 'demo_aissatou', day: 2, h: 6,  m: 30, price: 15000, seats: 4, taken: 1, instant: false },
  { from: 'Dakar',       to: 'Kaolack',     driver: 'demo_moussa',   day: 1, h: 14, m: 0,  price: 5000,  seats: 4, taken: 2, instant: true  },
  { from: 'Thiès',       to: 'Dakar',       driver: 'demo_ndeye',    day: 0, h: 18, m: 30, price: 2000,  seats: 3, taken: 2, instant: true  },
  { from: 'Dakar',       to: 'Fatick',      driver: 'demo_fatou',    day: 1, h: 8,  m: 0,  price: 4000,  seats: 3, taken: 0, instant: true  },
  { from: 'Dakar',       to: 'Saint-Louis', driver: 'demo_moussa',   day: 2, h: 13, m: 0,  price: 6500,  seats: 4, taken: 3, instant: false },
  { from: 'Dakar',       to: 'Thiès',       driver: 'demo_ibrahima', day: 0, h: 16, m: 0,  price: 2000,  seats: 3, taken: 1, instant: true  },
  { from: 'Dakar',       to: 'Saint-Louis', driver: 'demo_fatou',    day: 1, h: 7,  m: 30, price: 6000,  seats: 4, taken: 1, instant: true  },
  { from: 'Dakar',       to: 'Thiès',       driver: 'demo_amadou',   day: 0, h: 7,  m: 0,  price: 1500,  seats: 4, taken: 1, instant: true  },
];

const driverBy = (uid) => DRIVERS.find((d) => d.uid === uid);

// --- ecritures --------------------------------------------------------------

async function seedDrivers() {
  for (const d of DRIVERS) {
    await setDoc('users', d.uid, {
      name: S(d.name),
      phone: S(d.phone),
      car: S(d.car),
      smokeFree: B(d.smokeFree),
      petsAllowed: B(d.petsAllowed),
      music: B(d.music),
      readReceipts: B(true),
      verified: B(d.verified),
      verificationRequested: B(false),
      demoSeed: B(true),
    });
    console.log(`  users/${d.uid}  ${d.name}`);
  }
}

async function seedRides() {
  const created = [];
  // createdAt espace d'une minute pour figer l'ordre d'affichage
  const base = Date.now() - RIDES.length * 60000;
  for (let i = 0; i < RIDES.length; i++) {
    const r = RIDES[i];
    const driver = driverBy(r.driver);
    const from = REGIONS[r.from];
    const to = REGIONS[r.to];
    const doc = await addDoc('rides', {
      from: S(r.from),
      to: S(r.to),
      fromLat: D(from[0]),
      fromLng: D(from[1]),
      toLat: D(to[0]),
      toLng: D(to[1]),
      departure: T(at(r.day, r.h, r.m)),
      durationMinutes: I(durationMinutes(from, to)),
      seats: I(r.seats - r.taken),
      seatsTotal: I(r.seats),
      price: D(r.price),
      instantBooking: B(r.instant),
      driverUid: S(driver.uid),
      driverName: S(driver.name),
      driverCar: S(driver.car),
      createdAt: T(new Date(base + i * 60000)),
      demoSeed: B(true),
    });
    const id = doc.name.split('/').pop();
    created.push({ id, ...r, driver });
    console.log(
      `  rides/${id}  ${r.from} -> ${r.to}  ${r.price} FCFA  (${r.seats - r.taken}/${r.seats} places)`,
    );
  }
  return created;
}

async function seedForUser(uid, rides) {
  const me = 'Vous';

  // 1. Deux reservations : une a venir, une passee.
  const upcoming = rides.find((r) => r.from === 'Dakar' && r.to === 'Saint-Louis');
  const past = rides.find((r) => r.from === 'Thiès' && r.to === 'Dakar');

  for (const [ride, offset] of [[upcoming, -2], [past, -9]]) {
    if (!ride) continue;
    const isPast = offset < -5;
    await addDoc('bookings', {
      uid: S(uid),
      rideId: S(ride.id),
      from: S(ride.from),
      to: S(ride.to),
      departure: T(isPast ? at(-6, ride.h, ride.m) : at(ride.day, ride.h, ride.m)),
      price: D(ride.price),
      driverUid: S(ride.driver.uid),
      driverName: S(ride.driver.name),
      createdAt: T(at(offset, 10, 0)),
      demoSeed: B(true),
    });
    console.log(`  bookings/  ${ride.from} -> ${ride.to} avec ${ride.driver.name}`);
  }

  // 2. Notifications recentes.
  const notifs = [
    ['Réservation confirmée', `Votre place pour ${upcoming ? upcoming.from : 'Dakar'} → ${upcoming ? upcoming.to : 'Saint-Louis'} est confirmée.`, 40],
    ['Nouveau message', `${upcoming ? upcoming.driver.name : 'Amadou Diallo'} vous a envoyé un message.`, 25],
    ['Départ imminent', 'Votre conducteur sera au point de rendez-vous dans 30 minutes.', 8],
  ];
  for (const [title, body, minutesAgo] of notifs) {
    await addDoc('notifications', {
      forUid: S(uid),
      title: S(title),
      body: S(body),
      createdAt: T(new Date(Date.now() - minutesAgo * 60000)),
      demoSeed: B(true),
    });
    console.log(`  notifications/  ${title}`);
  }

  // 3. Une conversation deja entamee avec le conducteur du trajet a venir.
  const other = upcoming ? upcoming.driver : DRIVERS[0];
  const convId = [uid, other.uid].sort().join('_');
  const thread = [
    [other.uid, 'Bonjour ! Merci pour la réservation. On part de la station Total de Liberté 6.', 180],
    [uid, 'Parfait. Je serai là à 12h45, j’ai une petite valise, ça passe ?', 168],
    [other.uid, 'Aucun souci, le coffre est vide. À demain !', 155],
    [other.uid, 'Je vous envoie ma position dès que je démarre.', 30],
  ];
  const names = {};
  names[uid] = S(me);
  names[other.uid] = S(other.name);
  await setDoc('conversations', convId, {
    participantUids: A([S(uid), S(other.uid)]),
    participantNames: M(names),
    lastMessage: S(thread[thread.length - 1][1]),
    lastMessageAt: T(new Date(Date.now() - 30 * 60000)),
    demoSeed: B(true),
  });
  for (const [senderUid, text, minutesAgo] of thread) {
    await addDoc(`conversations/${convId}/messages`, {
      text: S(text),
      senderUid: S(senderUid),
      sentAt: T(new Date(Date.now() - minutesAgo * 60000)),
    });
  }
  console.log(`  conversations/${convId}  ${thread.length} messages avec ${other.name}`);

  // 4. Un trajet publie par l'utilisateur : il apparait cote conducteur.
  const from = REGIONS['Dakar'];
  const to = REGIONS['Fatick'];
  await addDoc('rides', {
    from: S('Dakar'),
    to: S('Fatick'),
    fromLat: D(from[0]),
    fromLng: D(from[1]),
    toLat: D(to[0]),
    toLng: D(to[1]),
    departure: T(at(3, 9, 0)),
    durationMinutes: I(durationMinutes(from, to)),
    seats: I(2),
    seatsTotal: I(3),
    price: D(4000),
    instantBooking: B(true),
    driverUid: S(uid),
    driverName: S('Vous'),
    driverCar: S('Toyota Yaris grise'),
    createdAt: T(new Date(Date.now() - 3 * 3600000)),
    demoSeed: B(true),
  });
  console.log('  rides/  Dakar -> Fatick publié par vous (côté conducteur)');
}

// --- nettoyage --------------------------------------------------------------

async function reset() {
  let removed = 0;
  for (const collection of ['rides', 'bookings', 'notifications', 'users']) {
    const res = await listDocs(collection);
    for (const doc of res.documents || []) {
      if (!doc.fields || !doc.fields.demoSeed || doc.fields.demoSeed.booleanValue !== true) continue;
      await deleteDoc(doc.name.split('/documents/')[1]);
      removed++;
    }
  }
  const convs = await listDocs('conversations');
  for (const doc of convs.documents || []) {
    if (!doc.fields || !doc.fields.demoSeed || doc.fields.demoSeed.booleanValue !== true) continue;
    const path = doc.name.split('/documents/')[1];
    const msgs = await listDocs(`${path}/messages`);
    for (const m of msgs.documents || []) {
      await deleteDoc(m.name.split('/documents/')[1]);
      removed++;
    }
    await deleteDoc(path);
    removed++;
  }
  console.log(`\n${removed} document(s) de démo supprimé(s).`);
}

async function listUsers() {
  const res = await listDocs('users');
  console.log('\nDocuments users existants :\n');
  for (const doc of res.documents || []) {
    const uid = doc.name.split('/').pop();
    const name = (doc.fields && doc.fields.name && doc.fields.name.stringValue) || '(sans nom)';
    const demo = doc.fields && doc.fields.demoSeed && doc.fields.demoSeed.booleanValue === true ? '  [démo]' : '';
    console.log(`  ${uid.padEnd(30)} ${name}${demo}`);
  }
  console.log(
    '\nTon uid est celui qui porte le nom saisi dans l’onglet Profil de l’app.\n' +
      'Relance ensuite : node tool/seed_demo_data.js --for-uid <uid>\n',
  );
}

// --- entree -----------------------------------------------------------------

async function main() {
  const args = process.argv.slice(2);
  const forUid = args.includes('--for-uid') ? args[args.indexOf('--for-uid') + 1] : null;

  console.log(`Connexion anonyme au projet ${PROJECT_ID}...`);
  await signInAnonymously();

  if (args.includes('--list-users')) return listUsers();
  if (args.includes('--reset')) return reset();

  console.log('\nConducteurs :');
  await seedDrivers();
  console.log('\nTrajets :');
  const rides = await seedRides();

  if (forUid) {
    console.log(`\nDonnées personnelles pour ${forUid} :`);
    await seedForUser(forUid, rides);
  } else {
    console.log(
      '\nAstuce : pour avoir aussi des réservations, notifications et une\n' +
        'conversation sur ton propre compte, saisis ton nom dans l’onglet Profil,\n' +
        'puis lance `node tool/seed_demo_data.js --list-users` pour trouver ton uid.',
    );
  }

  console.log(`\nTerminé. ${DRIVERS.length} conducteurs et ${RIDES.length} trajets en base.`);
}

main().catch((e) => {
  console.error('\nÉchec :', e.message);
  process.exit(1);
});
