<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Task; // Import Model Task
use Illuminate\Http\Request;

class TaskController extends Controller
{
    public function index()
    {
        // Mengambil semua data dari tabel tasks
        $tasks = Task::all();
        
        // Mengembalikan data dalam format JSON
        return response()->json([
            'success' => true,
            'message' => 'Daftar tugas berhasil diambil',
            'data'    => $tasks
        ]);
    }
}