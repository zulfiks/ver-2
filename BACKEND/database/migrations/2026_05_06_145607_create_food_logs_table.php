<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
public function up(): void
    {
        Schema::create('food_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('food_id')->constrained('foods')->onDelete('cascade');
            $table->decimal('porsi', 5, 2); // Bisa 0.5 (setengah porsi), 1.0, 2.0
            $table->integer('total_kalori'); // Hasil kali (porsi * kalori_standar)
            $table->string('waktu_makan'); // Sarapan, Makan Siang, Malam, Snack
            $table->date('tanggal_catat'); // Tanggal makan
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('food_logs');
    }
};
