import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/student.dart';
import '../controllers/course_controller.dart';
import '../controllers/student_controller.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  final CourseController _courseController = CourseController();
  final StudentController _studentController = StudentController();

  final _courseFormKey = GlobalKey<FormState>();
  final _studentFormKey = GlobalKey<FormState>();

  // Controllers dos Inputs de Curso
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  final _coordinatorController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Controllers dos Inputs de Aluno
  final _studentNameController = TextEditingController();
  final _studentRaController = TextEditingController();
  final _studentEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _courseController.carregarCursos().then((_) => setState(() {}));
    _studentController.carregarAlunos().then((_) => setState(() {}));
  }

  // ==================== ABAS E NAVEGAÇÃO ====================
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sistema Acadêmico'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.book), text: 'Cursos'),
              Tab(icon: Icon(Icons.person), text: 'Alunos'),
            ],
          ),
        ),
        body: TabBarView(children: [_buildCourseTab(), _buildStudentTab()]),
      ),
    );
  }

  // ==================== ABA DE CURSOS ====================
  Widget _buildCourseTab() {
    return Scaffold(
      body: _courseController.courses.isEmpty
          ? const Center(child: Text('Nenhum curso cadastrado.'))
          : ListView.builder(
              itemCount: _courseController.courses.length,
              itemBuilder: (context, index) {
                final curso = _courseController.courses[index];
                return ListTile(
                  title: Text(curso.name),
                  subtitle: Text(
                    'Coord: ${curso.coordinator} | ${curso.duration} semestres',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _mostrarFormularioCurso(course: curso),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _confirmarRemocaoCurso(curso.courseId!),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioCurso(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _mostrarFormularioCurso({Course? course}) {
    if (course != null) {
      _nameController.text = course.name;
      _durationController.text = course.duration.toString();
      _coordinatorController.text = course.coordinator;
      _descriptionController.text = course.description;
    } else {
      _nameController.clear();
      _durationController.clear();
      _coordinatorController.clear();
      _descriptionController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Form(
          key: _courseFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                course == null ? 'Cadastrar Curso' : 'Editar Curso',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome do Curso'),
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duração (Semestres)',
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _coordinatorController,
                decoration: const InputDecoration(labelText: 'Coordenador'),
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 2,
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_courseFormKey.currentState!.validate()) {
                    final novoCurso = Course(
                      courseId: course?.courseId,
                      name: _nameController.text,
                      duration: int.parse(_durationController.text),
                      coordinator: _coordinatorController.text,
                      description: _descriptionController.text,
                    );
                    if (course == null) {
                      await _courseController.adicionarCurso(novoCurso);
                    } else {
                      await _courseController.atualizarCurso(novoCurso);
                    }
                    Navigator.pop(context);
                    setState(() {});
                    _exibirSnackBar('Operação realizada no curso!');
                  }
                },
                child: Text(course == null ? 'Salvar' : 'Atualizar'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmarRemocaoCurso(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Remoção'),
        content: const Text('Deseja realmente excluir este curso?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await _courseController.removerCurso(id);
              Navigator.pop(context);
              setState(() {});
              _exibirSnackBar('Curso removido!');
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ==================== ABA DE ALUNOS (FUNCIONALIDADE BÔNUS IA) ====================
  Widget _buildStudentTab() {
    return Scaffold(
      body: _studentController.students.isEmpty
          ? const Center(child: Text('Nenhum aluno cadastrado.'))
          : ListView.builder(
              itemCount: _studentController.students.length,
              itemBuilder: (context, index) {
                final aluno = _studentController.students[index];
                return ListTile(
                  title: Text(aluno.name),
                  subtitle: Text('RA: ${aluno.ra} | Email: ${aluno.email}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () =>
                            _mostrarFormularioAluno(student: aluno),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _confirmarRemocaoAluno(aluno.studentId!),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioAluno(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _mostrarFormularioAluno({Student? student}) {
    if (student != null) {
      _studentNameController.text = student.name;
      _studentRaController.text = student.ra;
      _studentEmailController.text = student.email;
    } else {
      _studentNameController.clear();
      _studentRaController.clear();
      _studentEmailController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Form(
          key: _studentFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                student == null ? 'Cadastrar Aluno' : 'Editar Aluno',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                controller: _studentNameController,
                decoration: const InputDecoration(labelText: 'Nome do Aluno'),
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _studentRaController,
                decoration: const InputDecoration(
                  labelText: 'Registro Acadêmico (RA)',
                ),
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _studentEmailController,
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_studentFormKey.currentState!.validate()) {
                    final novoAluno = Student(
                      studentId: student?.studentId,
                      name: _studentNameController.text,
                      ra: _studentRaController.text,
                      email: _studentEmailController.text,
                    );
                    if (student == null) {
                      await _studentController.adicionarAluno(novoAluno);
                    } else {
                      await _studentController.atualizarAluno(novoAluno);
                    }
                    Navigator.pop(context);
                    setState(() {});
                    _exibirSnackBar('Operação realizada no aluno!');
                  }
                },
                child: Text(student == null ? 'Salvar' : 'Atualizar'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmarRemocaoAluno(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Remoção'),
        content: const Text('Deseja realmente excluir este aluno?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await _studentController.removerAluno(id);
              Navigator.pop(context);
              setState(() {});
              _exibirSnackBar('Aluno removido!');
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _exibirSnackBar(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }
}
