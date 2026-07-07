import { IsOptional, IsString, IsInt } from 'class-validator';

export class UpdateCallDto {
  @IsOptional()
  @IsInt()
  duration?: number;

  @IsOptional()
  @IsString()
  status?: string;

  @IsOptional()
  @IsString()
  transcript?: string;

  @IsOptional()
  @IsString()
  summary?: string;

  @IsOptional()
  @IsString()
  recordingUrl?: string;

  @IsOptional()
  @IsString()
  intent?: string;

  @IsOptional()
  @IsString()
  outcome?: string;

  @IsOptional()
  @IsString()
  voicemailUrl?: string;
}
