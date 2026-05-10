<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6',
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            // Simpan data dari Flutter ke Database
            'pola_makan' => $request->pola_makan,
            'jam_makan' => $request->jam_makan,
            'ngemil' => $request->ngemil,
            'gula' => $request->gula,
            'aktivitas' => $request->aktivitas,
            'tidur' => $request->tidur,
            'stres' => $request->stres,
            'riwayat' => $request->riwayat,
            'penyakit' => $request->penyakit,
            'klasifikasi_risiko' => $request->klasifikasi_risiko,
        ]);

        return response()->json([
            'message' => 'Registrasi berhasil!',
            'user' => $user
        ], 201);
    }
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required'
        ]);

        $user = User::where('email', $request->email)->first();

        // Cek apakah user ada dan password cocok
        if (! $user || ! Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Email atau Password salah!'
            ], 401);
        }

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil',
            'user' => $user
        ], 200);
    }
}