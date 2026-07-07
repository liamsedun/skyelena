import { IsOptional, IsString } from 'class-validator';

export class UpdateSettingsDto {
  @IsOptional()
  @IsString()
  businessName?: string;

  @IsOptional()
  @IsString()
  businessHours?: string;

  @IsOptional()
  @IsString()
  aiTone?: string;

  @IsOptional()
  @IsString()
  aiVoice?: string;

  @IsOptional()
  @IsString()
  greetingMessage?: string;

  @IsOptional()
  @IsString()
  emergencyRule?: string;

  @IsOptional()
  @IsString()
  emergencyNumber?: string;

  @IsOptional()
  @IsString()
  autoReply?: string;

  @IsOptional()
  @IsString()
  timezone?: string;
}
