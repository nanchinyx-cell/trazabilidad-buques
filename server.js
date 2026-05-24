const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());
app.use(express.static(__dirname));

// Base de datos simulada con datos en tiempo real
let buques = [
  { id: 1, nombre: 'BUQUE GLOBAL', latitud: -25.5, longitud: -57.5, estado: 'En Tránsito', puerto: 'Villeta', fecha: new Date().toISOString().split('T')[0], velocidad: 12.5, rumbo: 45 },
  { id: 2, nombre: 'BUQUE MARITIME', latitud: -32.95, longitud: -60.66, estado: 'Atracado', puerto: 'Rosario', fecha: new Date().toISOString().split('T')[0], velocidad: 0, rumbo: 0 },
  { id: 3, nombre: 'BUQUE NAVIOS', latitud: -34.6, longitud: -58.37, estado: 'En Tránsito', puerto: 'Buenos Aires', fecha: new Date().toISOString().split('T')[0], velocidad: 15.3, rumbo: 90 },
  { id: 4, nombre: 'BUQUE PUERTO', latitud: -34.9, longitud: -56.2, estado: 'Atracado', puerto: 'Montevideo', fecha: new Date().toISOString().split('T')[0], velocidad: 0, rumbo: 0 },
  { id: 5, nombre: 'BUQUE BRASIL', latitud: -23.95, longitud: -46.33, estado: 'En Tránsito', puerto: 'Santos', fecha: new Date().toISOString().split('T')[0], velocidad: 18.2, rumbo: 135 }
];

// API: Obtener todos los buques
app.get('/api/buques', (req, res) => {
  res.json(buques);
});

// API: Obtener un buque por ID
app.get('/api/buques/:id', (req, res) => {
  const buque = buques.find(b => b.id === parseInt(req.params.id));
  if (buque) {
    res.json(buque);
  } else {
    res.status(404).json({ error: 'Buque no encontrado' });
  }
});

// API: Crear un nuevo buque
app.post('/api/buques', (req, res) => {
  const nuevobuque = {
    id: Math.max(...buques.map(b => b.id), 0) + 1,
    ...req.body,
    fecha: new Date().toISOString().split('T')[0]
  };
  buques.push(nuevobuque);
  res.status(201).json(nuevobuque);
});

// API: Actualizar posición de un buque (TIEMPO REAL)
app.put('/api/buques/:id', (req, res) => {
  const buque = buques.find(b => b.id === parseInt(req.params.id));
  if (buque) {
    Object.assign(buque, req.body);
    res.json(buque);
  } else {
    res.status(404).json({ error: 'Buque no encontrado' });
  }
});

// API: Eliminar un buque
app.delete('/api/buques/:id', (req, res) => {
  buques = buques.filter(b => b.id !== parseInt(req.params.id));
  res.json({ mensaje: 'Buque eliminado' });
});

// Simular actualizaciones de posición en tiempo real
setInterval(() => {
  buques.forEach(buque => {
    if (buque.estado === 'En Tránsito') {
      // Movimiento realista
      const variation = (Math.random() - 0.5) * 0.08;
      buque.latitud += variation;
      buque.longitud += variation;
      
      // Variar velocidad entre 10-20 nudos
      buque.velocidad = 10 + Math.random() * 10;
      
      // Variar rumbo entre 0-360 grados
      buque.rumbo = Math.floor(Math.random() * 360);
    }
  });
}, 3000);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Servidor ejecutándose en http://localhost:${PORT}`);
  console.log(`📊 API disponible en http://localhost:${PORT}/api/buques`);
  console.log(`🗺️ Aplicación en http://localhost:${PORT}`);
});