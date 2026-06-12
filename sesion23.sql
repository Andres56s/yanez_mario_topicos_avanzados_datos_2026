--Sesion 23 


--Diseña un modelo NoSQL para el esquema curso_topicos. Documenta en comentarios cómo estructurarías los datos en MongoDB (por ejemplo, qué datos embebes y por qué). Proporciona un ejemplo de un documento.

{
  "_id": ObjectId("647a1f2b8c9d0a1b2c3d4e5f"),
  "clienteID": 1024,
  "nombre": "Yerko Alvarez",
  "contacto": {
    "email": "yerko.alvarez@email.cl",
    "telefono": "+56912345678"
  },
  "pedidos": [
    {
      "pedidoID": 5001,
      "fechaPedido": ISODate("2025-03-15T14:30:00Z"),
      "total": 150000,
      "estado": "Entregado",
      "items": [
        {
          "productoID": 88,
          "descripcion": "Disco Duro SSD 1TB",
          "cantidad": 1,
          "precioUnitario": 150000
        }
      ]
    },
    {
      "pedidoID": 5028,
      "fechaPedido": ISODate("2025-06-20T10:15:00Z"),
      "total": 45000,
      "estado": "Procesando",
      "items": [
        {
          "productoID": 42,
          "descripcion": "Cable DisplayPort 1.4 Ugreen",
          "cantidad": 2,
          "precioUnitario": 22500
        }
      ]
    }
  ],
  "metadata": {
    "fechaRegistro": ISODate("2024-01-10T08:00:00Z"),
    "activo": true
  }
}

---Escribe dos consultas en MongoDB: 
---Una para obtener los clientes de una ciudad específica (por ejemplo, Santiago).
---Otra para calcular el número total de productos vendidos por producto.

---Consulta básica utilizando el método find()
db.clientes.find(
  { "contacto.ciudad": "Santiago" }, // Filtro de búsqueda
  { "nombre": 1, "contacto.email": 1, "_id": 0 } // Proyección: Solo muestra nombre y email
);



---Consulta avanzada usando el Pipeline de Agregación
db.clientes.aggregate([
  // 1. Desarmar el arreglo de pedidos para tratar cada pedido de forma individual
  { $unwind: "$pedidos" },
  
  // 2. Desarmar el arreglo de items dentro de cada pedido para liberar los productos
  { $unwind: "$pedidos.items" },
  
  // 3. Agrupar por el ID o descripción del producto y sumar las cantidades
  {
    $group: {
      _id: {
        productoID: "$pedidos.items.productoID",
        descripcion: "$pedidos.items.descripcion"
      },
      TotalUnidadesSold: { $sum: "$pedidos.items.cantidad" }
    }
  },
  
  // 4. Ordenar los resultados de mayor a menor cantidad vendida (Opcional)
  { $sort: { TotalUnidadesSold: -1 } }
]);

