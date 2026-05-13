<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('screenings', function (Blueprint $table) {


            // TAMBAHAN FIELD BARU
            $table->integer('age')->nullable();

            $table->string('activity_level')->nullable();
            $table->string('sweet_drink')->nullable();
            $table->string('fast_food')->nullable();
            $table->string('sleep_duration')->nullable();
            $table->string('sitting_duration')->nullable();
            $table->string('fatigue')->nullable();

            $table->json('conditions')->nullable();

            // ANALYSIS RESULT
            $table->string('activity_risk')->nullable();
            $table->string('nutrition_risk')->nullable();
            $table->string('sleep_risk')->nullable();
            $table->string('health_risk')->nullable();
            $table->string('overall_risk')->nullable();
        });
    }

    public function down(): void
    {
        Schema::table('screenings', function (Blueprint $table) {

            $table->dropColumn([
                'age',
                'activity_level',
                'sweet_drink',
                'fast_food',
                'sleep_duration',
                'sitting_duration',
                'fatigue',
                'conditions',

                'activity_risk',
                'nutrition_risk',
                'sleep_risk',
                'health_risk',
                'overall_risk',
            ]);

        });
    }
};