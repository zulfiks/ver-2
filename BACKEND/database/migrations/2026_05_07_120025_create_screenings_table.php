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
        Schema::create('screenings', function (Blueprint $table) {
            $table->id();
            $table->float('weight'); // Berat badan (kg) [cite: 263]
            $table->float('height'); // Tinggi badan (cm) [cite: 266]
            $table->enum('gender', ['male', 'female']); // Jenis kelamin 
            $table->float('waist'); // Lingkar pinggang (cm) [cite: 279]
            $table->integer('sarc_f_score'); // Skor kuesioner SARC-F 
            $table->float('imt_value'); // Nilai IMT hasil hitung 
            $table->string('imt_classification'); // Normal, Obesitas I, dll 
            $table->string('risk_level'); // Risiko komorbid 
            $table->string('central_obesity_status'); // Obesitas Sentral/Normal 
            $table->string('sarcopenia_status'); // Status berdasarkan skor SARC-F [cite: 497]
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('screenings');
    }
};