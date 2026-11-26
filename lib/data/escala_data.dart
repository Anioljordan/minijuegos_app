/// Escalas de la app agrupadas por categoría.
const List<String> categoriasEscala = [
  'Comida',
  'Planes',
  'Amor',
  'Estilo',
  'Cultura',
  'Vida',
];

const List<Map<String, String>> escalasJuego = [
  {
    'izquierda': 'Comida rica',
    'derecha': 'Comida mala',
    'categoria': 'Comida',
  },
  {
    'izquierda': 'Comida de valientes',
    'derecha': 'Comida apta para todos',
    'categoria': 'Comida',
  },
  {
    'izquierda': 'Desayuno perfecto',
    'derecha': 'Desayuno horrible',
    'categoria': 'Comida',
  },
  {
    'izquierda': 'Placer sin culpa',
    'derecha': 'Placer culpable',
    'categoria': 'Comida',
  },
  {
    'izquierda': 'Postre increíble',
    'derecha': 'Postre triste',
    'categoria': 'Comida',
  },
  {
    'izquierda': 'Huele genial',
    'derecha': 'Huele fatal',
    'categoria': 'Comida',
  },
  {
    'izquierda': 'Planazo',
    'derecha': 'Plan horrible',
    'categoria': 'Planes',
  },
  {
    'izquierda': 'Muy divertido',
    'derecha': 'Muy aburrido',
    'categoria': 'Planes',
  },
  {
    'izquierda': 'Muy relajante',
    'derecha': 'Muy estresante',
    'categoria': 'Planes',
  },
  {
    'izquierda': 'Plan para repetir',
    'derecha': 'Plan para olvidar',
    'categoria': 'Planes',
  },
  {
    'izquierda': 'Fiesta épica',
    'derecha': 'Fiesta muerta',
    'categoria': 'Planes',
  },
  {
    'izquierda': 'Viaje soñado',
    'derecha': 'Viaje pesadilla',
    'categoria': 'Planes',
  },
  {
    'izquierda': 'Muy sexy',
    'derecha': 'Nada sexy',
    'categoria': 'Amor',
  },
  {
    'izquierda': 'Muy romántico',
    'derecha': 'Nada romántico',
    'categoria': 'Amor',
  },
  {
    'izquierda': 'Primera cita ideal',
    'derecha': 'Primera cita desastre',
    'categoria': 'Amor',
  },
  {
    'izquierda': 'Green flag',
    'derecha': 'Red flag',
    'categoria': 'Amor',
  },
  {
    'izquierda': 'Nada celoso',
    'derecha': 'Muy celoso',
    'categoria': 'Amor',
  },
  {
    'izquierda': 'Ligue fácil',
    'derecha': 'Ligue imposible',
    'categoria': 'Amor',
  },
  {
    'izquierda': 'Vale cada euro',
    'derecha': 'Tirar el dinero',
    'categoria': 'Estilo',
  },
  {
    'izquierda': 'Muy elegante',
    'derecha': 'Muy cutre',
    'categoria': 'Estilo',
  },
  {
    'izquierda': 'Muy moderno',
    'derecha': 'Muy anticuado',
    'categoria': 'Estilo',
  },
  {
    'izquierda': 'Capricho justificado',
    'derecha': 'Capricho absurdo',
    'categoria': 'Estilo',
  },
  {
    'izquierda': 'Regalo perfecto',
    'derecha': 'Regalo horrible',
    'categoria': 'Estilo',
  },
  {
    'izquierda': 'De moda',
    'derecha': 'Pasado de moda',
    'categoria': 'Estilo',
  },
  {
    'izquierda': 'Peli de culto',
    'derecha': 'Peli olvidable',
    'categoria': 'Cultura',
  },
  {
    'izquierda': 'Canción para bailar',
    'derecha': 'Canción para llorar',
    'categoria': 'Cultura',
  },
  {
    'izquierda': 'Mejor serie',
    'derecha': 'Peor serie',
    'categoria': 'Cultura',
  },
  {
    'izquierda': 'Famoso que mola',
    'derecha': 'Famoso insoportable',
    'categoria': 'Cultura',
  },
  {
    'izquierda': 'Libro obligatorio',
    'derecha': 'Libro infumable',
    'categoria': 'Cultura',
  },
  {
    'izquierda': 'Leyenda',
    'derecha': 'Olvidado',
    'categoria': 'Cultura',
  },
  {
    'izquierda': 'Muy útil',
    'derecha': 'Inútil',
    'categoria': 'Vida',
  },
  {
    'izquierda': 'Riesgo que merece la pena',
    'derecha': 'Locura total',
    'categoria': 'Vida',
  },
  {
    'izquierda': 'Cualquiera puede hacerlo',
    'derecha': 'Solo un genio',
    'categoria': 'Vida',
  },
  {
    'izquierda': 'Superpoder genial',
    'derecha': 'Superpoder inútil',
    'categoria': 'Vida',
  },
  {
    'izquierda': 'Nada vergonzoso',
    'derecha': 'Muy vergonzoso',
    'categoria': 'Vida',
  },
  {
    'izquierda': 'Trabajo soñado',
    'derecha': 'Trabajo pesadilla',
    'categoria': 'Vida',
  },
  {
    'izquierda': 'Comida sobrevalorada',
    'derecha': 'Comida infravalorada',
    'categoria': 'Comida',
  },
  {
    'izquierda': 'Comida para una cita',
    'derecha': 'Comida de domingo en el sofá',
    'categoria': 'Comida',
  },
  {
    'izquierda': 'Ingrediente que mejora todo',
    'derecha': 'Ingrediente que lo estropea todo',
    'categoria': 'Comida',
  },
  {
    'izquierda': 'Comida de abuela',
    'derecha': 'Comida de influencer',
    'categoria': 'Comida',
  },
  {
    'izquierda': 'Para compartir',
    'derecha': 'No se comparte ni loco',
    'categoria': 'Comida',
  },
  {
    'izquierda': 'Merienda de campeón',
    'derecha': 'Merienda triste',
    'categoria': 'Comida',
  },
  {
    'izquierda': 'Plan de introvertido',
    'derecha': 'Plan de extrovertido',
    'categoria': 'Planes',
  },
  {
    'izquierda': 'Plan de domingo',
    'derecha': 'Plan de sábado noche',
    'categoria': 'Planes',
  },
  {
    'izquierda': 'Plan que nunca cancelas',
    'derecha': 'Plan que cancelas sin pena',
    'categoria': 'Planes',
  },
  {
    'izquierda': 'Plan para hacer en pareja',
    'derecha': 'Plan para hacer con amigos',
    'categoria': 'Planes',
  },
  {
    'izquierda': 'Disfraz de 10',
    'derecha': 'Disfraz de 0',
    'categoria': 'Planes',
  },
  {
    'izquierda': 'Ciudad emocionante',
    'derecha': 'Ciudad aburrida',
    'categoria': 'Planes',
  },
  {
    'izquierda': 'Detalle bonito',
    'derecha': 'Detalle cringe',
    'categoria': 'Amor',
  },
  {
    'izquierda': 'Perdonable',
    'derecha': 'Motivo para cortar',
    'categoria': 'Amor',
  },
  {
    'izquierda': 'Te hace más atractivo',
    'derecha': 'Te quita puntos',
    'categoria': 'Amor',
  },
  {
    'izquierda': 'Buen tema en una primera cita',
    'derecha': 'Tema prohibido en una primera cita',
    'categoria': 'Amor',
  },
  {
    'izquierda': 'Normal en una pareja',
    'derecha': 'Tóxico',
    'categoria': 'Amor',
  },
  {
    'izquierda': 'Mensaje que respondes al momento',
    'derecha': 'Mensaje que dejas en visto',
    'categoria': 'Amor',
  },
  {
    'izquierda': 'Muy de pijo',
    'derecha': 'Muy de barrio',
    'categoria': 'Estilo',
  },
  {
    'izquierda': 'Cosa de boomer',
    'derecha': 'Cosa de Gen Z',
    'categoria': 'Estilo',
  },
  {
    'izquierda': 'Está volviendo',
    'derecha': 'Que no vuelva nunca',
    'categoria': 'Estilo',
  },
  {
    'izquierda': 'Regalo de compromiso',
    'derecha': 'Regalo de corazón',
    'categoria': 'Estilo',
  },
  {
    'izquierda': 'Canción para el coche',
    'derecha': 'Canción que quitas al momento',
    'categoria': 'Cultura',
  },
  {
    'izquierda': 'Peli para ver en pareja',
    'derecha': 'Peli para ver solo',
    'categoria': 'Cultura',
  },
  {
    'izquierda': 'Cantante sobrevalorado',
    'derecha': 'Cantante infravalorado',
    'categoria': 'Cultura',
  },
  {
    'izquierda': 'Mejor villano',
    'derecha': 'Peor villano',
    'categoria': 'Cultura',
  },
  {
    'izquierda': 'Serie que todos deberían ver',
    'derecha': 'Serie que nadie debería ver',
    'categoria': 'Cultura',
  },
  {
    'izquierda': 'Mejor invento',
    'derecha': 'Peor invento',
    'categoria': 'Vida',
  },
  {
    'izquierda': 'Buena excusa',
    'derecha': 'Excusa terrible',
    'categoria': 'Vida',
  },
  {
    'izquierda': 'Mentira piadosa',
    'derecha': 'Mentira imperdonable',
    'categoria': 'Vida',
  },
  {
    'izquierda': 'Totalmente aceptable',
    'derecha': 'Muy mala educación',
    'categoria': 'Vida',
  },
  {
    'izquierda': 'Se puede decir en una cena familiar',
    'derecha': 'Ni de broma en una cena familiar',
    'categoria': 'Vida',
  },
  {
    'izquierda': 'Talento útil',
    'derecha': 'Talento inútil',
    'categoria': 'Vida',
  },
  {
    'izquierda': 'Animal adorable',
    'derecha': 'Animal aterrador',
    'categoria': 'Vida',
  },
  {
    'izquierda': 'Trabajo sobrevalorado',
    'derecha': 'Trabajo infravalorado',
    'categoria': 'Vida',
  },
  {
    'izquierda': 'Cosa de niños',
    'derecha': 'Cosa de adultos',
    'categoria': 'Vida',
  },
  {
    'izquierda': 'Muy de mañanas',
    'derecha': 'Muy de noche',
    'categoria': 'Vida',
  },
  {
    'izquierda': 'Vicio aceptable',
    'derecha': 'Vicio preocupante',
    'categoria': 'Vida',
  },
];
