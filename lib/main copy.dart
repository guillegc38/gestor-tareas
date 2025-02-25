import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://rbxrumqslnnnuxpdtznq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJieHJ1bXFzbG5ubnV4cGR0em5xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAzMzY0ODYsImV4cCI6MjA1NTkxMjQ4Nn0.tzXYpWIUfTr0WQEJ2-3xWGi8w8TeUcNDKyZHsj29z3o',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestor de Tareas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Función para manejar la desconexión
  Future<void> _signOut() async {
    final response = await Supabase.instance.client.auth.signOut();
    if (response.error == null) {
      // Redirigir a la pantalla de inicio de sesión
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cerrar sesión: ${response.error?.message}")),
      );
    }
  }

  // Función para mostrar el AlertDialog de confirmación
  void _showSignOutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Cerrar sesión"),
          content: Text("¿Estás seguro de que quieres cerrar sesión?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Cierra el AlertDialog
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                _signOut(); // Llama a la función para cerrar sesión
                Navigator.of(context).pop();  // Cierra el AlertDialog
              },
              child: Text("Sí, cerrar sesión"),
            ),
          ],
        );
      },
    );
  }

  // Función que cambia la vista según la selección
  void _onItemTapped(int index) {
    if (index != 2) {  // Si no es el índice de Cerrar sesión, cambiamos de vista
      setState(() {
        _selectedIndex = index;
      });
    } else {
      // Si se seleccionó el botón de Cerrar sesión, mostramos el diálogo de confirmación
      _showSignOutConfirmation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gestor de Tareas")),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.task),
                label: Text('Ver tareas'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.add),
                label: Text('Crear tarea'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.exit_to_app),
                label: Text('Cerrar sesión'),
              ),
            ],
          ),
          Expanded(
            child: _selectedIndex == 0
                ? ViewTasksScreen()
                : _selectedIndex == 1
                    ? CreateTaskScreen()
                    : Container(), // No hay vista para "Cerrar sesión", la manejamos en el botón
          ),
        ],
      ),
    );
  }
}


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Estado para mostrar errores
  String? _errorMessage;

  // Función para manejar el inicio de sesión
  Future<void> _signIn() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    // Limpiar mensaje de error previo
    setState(() {
      _errorMessage = null;
    });

    // Validar si los campos no están vacíos
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "Por favor, ingrese su email y contraseña.";
      });
      return;
    }

    try {
      // Intentar iniciar sesión con Supabase
      final response = await Supabase.instance.client.auth.signIn(
        email: email,
        password: password,
      );

      if (response.error != null) {
        setState(() {
          _errorMessage = response.error?.message;
        });
      } else {
        // Si el login es exitoso, redirigir a la pantalla principal
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error al iniciar sesión: $e";
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Iniciar sesión")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Ingresa tu correo electrónico',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                hintText: 'Ingresa tu contraseña',
                border: OutlineInputBorder(),
              ),
              obscureText: true, // Ocultar la contraseña
            ),
            SizedBox(height: 16),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _signIn,
              child: Text("Iniciar sesión"),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Navegar a la pantalla de recuperación de contraseña
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PasswordRecoveryScreen()),
                );
              },
              child: Text("¿Olvidaste tu contraseña?"),
            ),
          ],
        ),
      ),
    );
  }
}

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  _PasswordRecoveryScreenState createState() =>
      _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final _emailController = TextEditingController();
  String? _errorMessage;
  String? _successMessage;

  // Función para recuperar la contraseña
  Future<void> _recoverPassword() async {
    final email = _emailController.text;

    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    // Verificamos que el campo de email no esté vacío
    if (email.isEmpty) {
      setState(() {
        _errorMessage = "Por favor, ingrese su email.";
      });
      return;
    }

    try {
      // Intentar enviar el enlace de recuperación de contraseña
      final response = await Supabase.instance.client.auth.api
          .resetPasswordForEmail(email);  // Método correcto de Supabase para recuperación de contraseña

      // Comprobamos si hubo algún error en la respuesta
      if (response.error != null) {
        setState(() {
          _errorMessage = response.error?.message;
        });
      } else {
        setState(() {
          _successMessage = "Enlace de recuperación enviado a tu correo.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error al enviar el enlace: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Recuperar contraseña")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Ingresa tu correo electrónico',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            if (_successMessage != null)
              Text(
                _successMessage!,
                style: TextStyle(color: Colors.green),
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _recoverPassword,
              child: Text("Recuperar contraseña"),
            ),
          ],
        ),
      ),
    );
  }
}



class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  _CreateTaskScreenState createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Función para agregar la tarea
  Future<void> addTask(String title, String description) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final response = await Supabase.instance.client.from('tasks').insert({
        'title': title,
        'description': description,
        'status': 'Pendiente',
        'user_id': user.id,  // ID del usuario autenticado
        'created_by_email': user.email,  // Email del usuario autenticado
      }).execute();

      if (response.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tarea agregada')));
        _titleController.clear();
        _descriptionController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${response.error?.message}')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Usuario no autenticado')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Descripción'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String title = _titleController.text;
                String description = _descriptionController.text;
                if (title.isNotEmpty && description.isNotEmpty) {
                  addTask(title, description);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Por favor complete todos los campos')));
                }
              },
              child: Text('Agregar Tarea'),
            ),
          ],
        ),
      ),
    );
  }
}


class ViewTasksScreen extends StatefulWidget {
  const ViewTasksScreen({super.key});

  @override
  _ViewTasksScreenState createState() => _ViewTasksScreenState();
}

class _ViewTasksScreenState extends State<ViewTasksScreen> {
  List<Map<String, dynamic>> tasks = [];

  // Esta función obtiene las tareas y sus datos relacionados
  Future<void> getTasks() async {
    final response = await Supabase.instance.client.from('tasks').select().execute();

    if (response.error == null) {
      setState(() {
        tasks = List<Map<String, dynamic>>.from(response.data);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${response.error?.message}')));
    }
  }

  @override
  void initState() {
    super.initState();
    getTasks();
  }

  // Función para formatear las fechas
  String formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tasks.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final createdAt = DateTime.parse(task['created_at']);
                final updatedAt = DateTime.parse(task['updated_at']);

                // Mostrar la fecha formateada
                final formattedCreatedAt = formatDate(createdAt);

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditTaskScreen(
                          task: task,
                          onTaskUpdated: getTasks,
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text(task['title']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Creado: $formattedCreatedAt'),
                        // Mostrar el email del creador de la tarea (usando el campo creado en la tarea)
                        Text('Creado por: ${task['created_by_email'] ?? 'Desconocido'}'),
                        Text('Última modificación: ${formatDate(updatedAt)}'),
                        Text("Última modificación: ${task['last_modified_by']?? 'Desconocido'}"),
                      ],
                    ),
                    trailing: Text(task['status']),
                  ),
                );
              },
            ),
    );
  }
}




class EditTaskScreen extends StatefulWidget {
  final Map<String, dynamic> task;
  final Function() onTaskUpdated; // Callback para actualizar la lista de tareas

  const EditTaskScreen({super.key, required this.task, required this.onTaskUpdated});

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String? _selectedStatus;

  // Lista de estados disponibles
  final List<String> statuses = ['Pendiente', 'En Progreso', 'Completada'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task['title']);
    _descriptionController = TextEditingController(text: widget.task['description']);
    _selectedStatus = widget.task['status'];
  }

  // Función para obtener el correo electrónico del usuario autenticado
  String getCurrentUserEmail() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      return user.email ?? 'Desconocido';
    } else {
      return 'Desconocido'; // Si no hay un usuario autenticado
    }
  }

  // Función para actualizar la tarea en Supabase
  Future<void> updateTask() async {
    final currentUserEmail = getCurrentUserEmail();  // Obtener el correo del usuario autenticado

    final response = await Supabase.instance.client.from('tasks').update({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'status': _selectedStatus,
      'last_modified_by': currentUserEmail,  // Guardar el correo en 'last_modified_by'
    }).eq('id', widget.task['id']).execute();

    if (response.error == null) {
      // Llamar al callback para actualizar la lista de tareas
      widget.onTaskUpdated();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tarea actualizada')));
      Navigator.pop(context);  // Volver a la pantalla anterior
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${response.error?.message}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Tarea'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Descripción'),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: _selectedStatus,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStatus = newValue;
                });
              },
              items: statuses.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateTask,
              child: Text('Guardar cambios'),
            ),
          ],
        ),
      ),
    );
  }
}





class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _taskDescriptionController = TextEditingController();
  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    getTasks();
  }

  Future<void> addTask(String title, String description) async {
  final user = Supabase.instance.client.auth.currentUser;

  if (user != null) {
    final response = await Supabase.instance.client
        .from('tasks')
        .insert({
          'title': title,
          'description': description,
          'user_id': user.id, // El ID del usuario es un UUID
          'status': 'pendiente',
        })
        .execute();

    if (response.error == null) {
      print('Tarea agregada');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tarea agregada')));
      _taskTitleController.clear();
      _taskDescriptionController.clear();
      getTasks(); // Refresca la lista de tareas
    } else {
      print('Error al agregar tarea: ${response.error?.message}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${response.error?.message}')));
    }
  }
}


  Future<void> getTasks() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      final response = await Supabase.instance.client
          .from('tasks')
          .select()
          .eq('user_id', user.id)
          .execute();

      if (response.error == null) {
        setState(() {
          tasks = List<Map<String, dynamic>>.from(response.data);
        });
      } else {
        print('Error al obtener tareas: ${response.error?.message}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mis Tareas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _taskTitleController,
              decoration: InputDecoration(labelText: 'Título de la tarea'),
            ),
            TextField(
              controller: _taskDescriptionController,
              decoration: InputDecoration(labelText: 'Descripción'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_taskTitleController.text.isNotEmpty && _taskDescriptionController.text.isNotEmpty) {
                  addTask(_taskTitleController.text, _taskDescriptionController.text);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Por favor, completa todos los campos')));
                }
              },
              child: Text('Agregar Tarea'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(tasks[index]['title']),
                    subtitle: Text(tasks[index]['description']),
                    trailing: Text(tasks[index]['status']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
