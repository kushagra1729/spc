# Generated by Django 2.0.5 on 2018-09-29 07:19

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('server', '0002_auto_20180929_0715'),
    ]

    operations = [
        migrations.AddField(
            model_name='document',
            name='description',
            field=models.CharField(blank=True, max_length=255),
        ),
    ]