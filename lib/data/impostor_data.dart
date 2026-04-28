/// ===============================
/// MODO 1 — CLÁSICO
/// ===============================

const List<Map<String, dynamic>> classicWordsData = [

  /// 🍔 COMIDA

  {
    'category': 'Comida',
    'hint': 'Se puede comer',
    'words': [
      'Pizza',
      'Hamburguesa',
      'Paella',
      'Sushi',
      'Tortilla',
      'Croqueta',
      'Hot dog',
      'Pasta',
      'Ensalada',
      'Burrito',
      'Kebab',
      'Tacos',
      'Ramen',
      'Lasaña',
      'Empanada',
    ]
  },

  /// 🐶 ANIMALES

  {
    'category': 'Animales',
    'hint': 'Es un ser vivo',
    'words': [
      'Perro',
      'Gato',
      'León',
      'Delfín',
      'Elefante',
      'Tigre',
      'Caballo',
      'Mono',
      'Oso',
      'Lobo',
      'Zorro',
      'Pingüino',
      'Koala',
      'Canguro',
      'Águila',
    ]
  },

  /// 🌍 LUGARES

  {
    'category': 'Lugares',
    'hint': 'Es un sitio',
    'words': [
      'Playa',
      'Discoteca',
      'Aeropuerto',
      'Hospital',
      'Colegio',
      'Restaurante',
      'Hotel',
      'Supermercado',
      'Parque',
      'Biblioteca',
      'Museo',
      'Estadio',
      'Cine',
      'Centro comercial',
    ]
  },

  /// 📱 OBJETOS

  {
    'category': 'Objetos',
    'hint': 'Se puede tocar',
    'words': [
      'Móvil',
      'Televisión',
      'Cuchara',
      'Zapato',
      'Ordenador',
      'Reloj',
      'Auriculares',
      'Gafas',
      'Mochila',
      'Ratón',
      'Teclado',
      'Cargador',
      'Botella',
      'Llaves',
    ]
  },

  /// 🎮 VIDEOJUEGOS

  {
    'category': 'Videojuegos',
    'hint': 'Es un juego',
    'words': [
      'Minecraft',
      'Fortnite',
      'Call of Duty',
      'FIFA',
      'GTA',
      'Mario Kart',
      'Zelda',
      'Among Us',
      'Valorant',
      'Clash Royale',
    ]
  },

  /// 🎬 CINE

  {
    'category': 'Películas',
    'hint': 'Es una película',
    'words': [
      'Titanic',
      'Avatar',
      'Frozen',
      'Toy Story',
      'Jurassic Park',
      'Harry Potter',
      'Spiderman',
      'Shrek',
      'Fast & Furious',
    ]
  },

];


/// ===============================
/// MODO 2 — ROLES
/// ===============================
const List<Map<String, dynamic>> rolesScenariosData = [

  {
    'place': 'Discoteca',
    'hint': 'Sitio de fiesta',
    'roles': [
      'DJ',
      'Portero',
      'Camarero',
      'Seguridad',
      'Cliente VIP',
      'Bailarín',
      'Barra',
    ]
  },

  {
    'place': 'Hospital',
    'hint': 'Lugar de salud',
    'roles': [
      'Médico',
      'Enfermero',
      'Paciente',
      'Recepcionista',
      'Cirujano',
      'Celador',
    ]
  },

  {
    'place': 'Avión',
    'hint': 'Medio de transporte',
    'roles': [
      'Piloto',
      'Azafata',
      'Pasajero',
      'Copiloto',
      'Mecánico',
    ]
  },

  {
    'place': 'Restaurante',
    'hint': 'Lugar donde se come',
    'roles': [
      'Camarero',
      'Cocinero',
      'Cliente',
      'Chef',
      'Encargado',
      'Lavaplatos',
    ]
  },

  {
    'place': 'Colegio',
    'hint': 'Lugar educativo',
    'roles': [
      'Profesor',
      'Alumno',
      'Director',
      'Conserje',
      'Tutor',
    ]
  },

  {
    'place': 'Playa',
    'hint': 'Lugar con arena',
    'roles': [
      'Socorrista',
      'Turista',
      'Surfista',
      'Vendedor',
      'Niño',
    ]
  },

  {
    'place': 'Supermercado',
    'hint': 'Lugar de compras',
    'roles': [
      'Cajero',
      'Cliente',
      'Reponedor',
      'Seguridad',
      'Gerente',
    ]
  },

  {
    'place': 'Cine',
    'hint': 'Lugar para ver películas',
    'roles': [
      'Espectador',
      'Proyeccionista',
      'Taquillero',
      'Vendedor de palomitas',
      'Seguridad',
    ]
  },

];
/// ===============================
/// MODO 3 — PREGUNTAS
/// ===============================
const List<Map<String, String>> questionPairsData = [

  {
    'normal': '¿Cuál es tu comida favorita?',
    'impostor': '¿Cuál es tu bebida favorita?',
    'hint': 'Habla de gustos',
  },

  {
    'normal': '¿Cuántas horas duermes?',
    'impostor': '¿A qué hora te duermes?',
    'hint': 'Relacionado con dormir',
  },

  {
    'normal': '¿Dónde trabajas?',
    'impostor': '¿Dónde estudias?',
    'hint': 'Habla de tu rutina',
  },

  {
    'normal': '¿Cuántos hermanos tienes?',
    'impostor': '¿Cuántos primos tienes?',
    'hint': 'Familia',
  },

  {
    'normal': '¿Cuál es tu serie favorita?',
    'impostor': '¿Cuál es tu película favorita?',
    'hint': 'Entretenimiento',
  },

  {
    'normal': '¿A qué hora comes?',
    'impostor': '¿A qué hora cenas?',
    'hint': 'Relacionado con comida',
  },

  {
    'normal': '¿Qué haces los fines de semana?',
    'impostor': '¿Qué haces entre semana?',
    'hint': 'Rutina',
  },

  {
    'normal': '¿Cuál es tu ciudad favorita?',
    'impostor': '¿Cuál es tu país favorito?',
    'hint': 'Viajes',
  },

];


/// ===============================
/// MODO 4 — DATOS FALSOS
/// ===============================
const List<Map<String, String>> curiousFactsData = [
  {
    'fact': 'Los pulpos tienen tres corazones.',
    'hint': 'Animales',
  },
  {
    'fact': 'La miel puede durar miles de años sin estropearse.',
    'hint': 'Comida',
  },
  {
    'fact': 'Los flamencos nacen grises, no rosas.',
    'hint': 'Animales',
  },
  {
    'fact': 'Un día en Venus dura más que un año en Venus.',
    'hint': 'Espacio',
  },
  {
    'fact': 'Los koalas tienen huellas dactilares muy parecidas a las humanas.',
    'hint': 'Animales',
  },
  {
    'fact': 'Los tiburones existen desde antes que los árboles.',
    'hint': 'Animales',
  },
  {
    'fact': 'Los plátanos son ligeramente radiactivos.',
    'hint': 'Comida',
  },
  {
    'fact': 'El corazón de una ballena azul puede pesar más de 180 kilos.',
    'hint': 'Animales',
  },
  {
    'fact': 'Las nutrias marinas se dan la mano mientras duermen.',
    'hint': 'Animales',
  },
  {
    'fact': 'En el espacio no se puede eructar de la misma forma que en la Tierra.',
    'hint': 'Espacio',
  },
  {
    'fact': 'Los caracoles pueden dormir durante varios años.',
    'hint': 'Animales',
  },
  {
    'fact': 'La Torre Eiffel puede crecer varios centímetros en verano por el calor.',
    'hint': 'Construcciones',
  },
  {
    'fact': 'Los gatos no pueden saborear el dulce.',
    'hint': 'Animales',
  },
  {
    'fact': 'Las jirafas tienen la misma cantidad de vértebras en el cuello que los humanos.',
    'hint': 'Animales',
  },
  {
    'fact': 'El Monte Everest sigue creciendo lentamente.',
    'hint': 'Naturaleza',
  },
  {
    'fact': 'Los cuervos pueden recordar caras humanas.',
    'hint': 'Animales',
  },
  {
    'fact': 'Hay más estrellas en el universo que granos de arena en la Tierra.',
    'hint': 'Espacio',
  },
  {
    'fact': 'Los caballitos de mar macho son los que llevan los huevos.',
    'hint': 'Animales',
  },
  {
    'fact': 'Las zanahorias originalmente no eran naranjas.',
    'hint': 'Comida',
  },
  {
    'fact': 'El hielo caliente existe bajo ciertas condiciones de presión.',
    'hint': 'Ciencia',
  },
];