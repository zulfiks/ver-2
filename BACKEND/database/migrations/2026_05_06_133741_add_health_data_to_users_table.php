<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // Menambahkan kolom untuk menyimpan form pop-up
            $table->string('pola_makan')->nullable();
            $table->string('jam_makan')->nullable();
            $table->string('ngemil')->nullable();
            $table->string('gula')->nullable();
            $table->string('aktivitas')->nullable();
            $table->string('tidur')->nullable();
            $table->string('stres')->nullable();
            $table->string('riwayat')->nullable();
            $table->string('penyakit')->nullable();
            $table->string('klasifikasi_risiko')->nullable(); // Menyimpan hasil output klasifikasi
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['pola_makan', 'jam_makan', 'ngemil', 'gula', 'aktivitas', 'tidur', 'stres', 'riwayat', 'penyakit', 'klasifikasi_risiko']);
        });
    }
};
