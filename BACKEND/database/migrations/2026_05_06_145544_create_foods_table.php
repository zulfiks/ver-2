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
    Schema::create('foods', function (Blueprint $table) {
        $table->id();
        $table->string('whatsapp_number');
        $table->string('nama_makanan'); // Pastikan tulisannya begini
        $table->integer('kalori_standar'); 
        $table->string('satuan_standar'); 
        $table->timestamps();
    });
}
    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('foods');
    }
};
